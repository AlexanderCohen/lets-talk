import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    static targets = ["playButton", "form", "phrasesList", "playStatus", "newCategory", "categoryContainer"]

    connect() {
        console.log("Phrases controller connected")
        this.currentAudio = null
        this.currentPlayingCard = null
        this.initializeSortable()
    }

    initializeSortable() {
        this.categoryContainerTargets.forEach(container => {
            Sortable.create(container, {
                group: "phrases",
                animation: 150,
                onEnd: this.handleDragEnd.bind(this)
            })
        })
    }

    play(event) {
        const card = event.currentTarget
        const audioUrl = card.dataset.audioUrl
        const playStatus = card.querySelector('[data-phrase-target="playStatus"]')
        console.log("Card clicked, audio URL:", audioUrl)

        // Stop current audio if it's playing
        if (this.currentAudio) {
            this.currentAudio.pause()
            this.currentAudio.currentTime = 0
            if (this.currentPlayingCard) {
                this.currentPlayingCard.querySelector('[data-phrase-target="playStatus"]').textContent = "Click to play"
                this.currentPlayingCard.classList.remove('bg-green-100')
            }
        }

        // If the clicked card is already playing, just stop and return
        if (this.currentPlayingCard === card) {
            this.currentAudio = null
            this.currentPlayingCard = null
            return
        }

        // Play the new audio
        if (audioUrl) {
            fetch(audioUrl, {
                credentials: 'same-origin',
                headers: {
                    'Accept': 'audio/mpeg,audio/*;q=0.8,*/*;q=0.5',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                }
            })
                .then(response => response.blob())
                .then(blob => {
                    const audio = new Audio(URL.createObjectURL(blob));
                    audio.play().then(() => {
                        console.log("Audio playing successfully")
                        playStatus.textContent = "Playing..."
                        card.classList.add('bg-green-100')
                        this.currentAudio = audio
                        this.currentPlayingCard = card

                        audio.onended = () => {
                            playStatus.textContent = "Click to play"
                            card.classList.remove('bg-green-100')
                            this.currentAudio = null
                            this.currentPlayingCard = null
                            URL.revokeObjectURL(audio.src) // Clean up the blob URL
                        }
                    }).catch(error => {
                        console.error("Error playing audio:", error)
                        alert("Error playing audio. Please try refreshing the page then trying again.")
                    })
                })
                .catch(error => {
                    console.error("Error fetching audio:", error)
                    alert("Error loading audio. Please try again.")
                })
        } else {
            console.log("No audio URL available")
            alert("Audio not available.")
        }
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    toggleNewCategory(event) {
        const selectedValue = event.target.value
        if (selectedValue === "") {
            this.newCategoryTarget.style.display = "block"
        } else {
            this.newCategoryTarget.style.display = "none"
            this.newCategoryTarget.value = "" // Clear the new category input when an existing category is selected
        }
    }

    createPhrase(event) {
        event.preventDefault()
        const form = event.target
        const formData = new FormData(form)

        // If a new category is entered, use it instead of the selected category
        const newCategory = formData.get('phrase[new_category]')
        if (newCategory) {
            formData.set('phrase[category]', newCategory)
        }

        fetch(form.action, {
            method: form.method,
            body: formData,
            headers: {
                "Accept": "text/vnd.turbo-stream.html"
            }
        })
            .then(response => response.text())
            .then(html => {
                Turbo.renderStreamMessage(html)
                form.reset()
                this.newCategoryTarget.style.display = "none"
            })
            .catch(error => {
                console.error("Error creating phrase:", error)
                alert("Error creating phrase. Please try again.")
            })
    }

    async share(event) {
        this.stopPropagation(event)
        event.preventDefault()

        const button = event.currentTarget
        const text = button.dataset.phraseText
        const audioUrl = button.dataset.phraseAudio

        try {
            console.log('Starting share process...')

            // Create a temporary anchor for downloading if Web Share API isn't available
            const createDownloadLink = (blob) => {
                const url = URL.createObjectURL(blob)
                const a = document.createElement('a')
                a.style.display = 'none'
                a.href = url
                a.download = 'audio.mp3'
                document.body.appendChild(a)
                return { element: a, url }
            }

            // Function to clean up temporary resources
            const cleanup = (element, url) => {
                if (element) document.body.removeChild(element)
                if (url) URL.revokeObjectURL(url)
            }

            // Attempt to fetch the audio file
            const response = await fetch(audioUrl, {
                method: 'GET',
                credentials: 'include',
                headers: {
                    'Accept': 'audio/mpeg,audio/*;q=0.8,*/*;q=0.5',
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                }
            })

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`)
            }

            const blob = await response.blob()

            // Try Web Share API first
            if (navigator.share) {
                try {
                    const file = new File([blob], 'audio.mp3', { type: 'audio/mpeg' })
                    await navigator.share({
                        text: text,
                        files: [file]
                    })
                    console.log('Shared successfully')
                } catch (shareError) {
                    if (shareError.name !== 'AbortError') {
                        // Fall back to download if share fails (but not if user cancelled)
                        const { element, url } = createDownloadLink(blob)
                        element.click()
                        cleanup(element, url)
                    }
                }
            } else {
                // Fall back to download if Web Share API isn't available
                const { element, url } = createDownloadLink(blob)
                element.click()
                cleanup(element, url)
            }
        } catch (error) {
            console.error('Error in share function:', error)
            alert('Sorry, there was a problem sharing the audio. Please try again.')
        }
    }

    disconnect() {
        if (this.currentAudio) {
            this.currentAudio.pause()
            this.currentAudio = null
        }
    }

    // Allow the User to drag and drop phrases into different categories
    handleDragEnd(event) {
        const phraseId = event.item.id.split('_')[1]
        const newCategory = event.to.dataset.category

        // Update the containers maxHeight to the new scrollHeight (which is set by expandable_controller)
        event.to.style.maxHeight = `${event.to.scrollHeight}px`

        fetch(`/phrases/${phraseId}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ phrase: { category: newCategory } })
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to update phrase category')
                }
            })
            .catch(error => {
                console.error('Error:', error)
            })
    }
}
