import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    static targets = ["playButton", "form", "phrasesList", "playStatus", "newCategory", "categoryContainer"]

    connect() {
        console.log("Phrases controller connected")
        this.initializeState()
        // disabling sortable for now and ensure that we can re-enable it later
        // this.initializeSortable()
    }

    // Initialize controller state
    initializeState() {
        this.currentAudio = null
        this.currentPlayingCard = null
        this.audioCache = new Map() // Cache for blob URLs
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

    // Audio playback handling
    async play(event) {
        try {
            const card = event.currentTarget
            const audioUrl = card.dataset.audioUrl
            const playStatus = card.querySelector('[data-phrase-target="playStatus"]')

            if (!audioUrl) {
                console.warn("No audio URL available")
                return
            }

            // Handle interruption of current playback
            await this.stopCurrentAudio()

            // If clicking the same card that was playing, just stop
            if (this.currentPlayingCard === card) {
                this.resetPlaybackState()
                return
            }

            // Fetch and play new audio
            await this.fetchAndPlayAudio(audioUrl, card, playStatus)
        } catch (error) {
            console.error("Error in play handler:", error)
            alert("Error playing audio. Please try again.")
        }
    }

    async stopCurrentAudio() {
        if (this.currentAudio) {
            await this.currentAudio.pause()
            this.currentAudio.currentTime = 0
            this.updatePlayingCardState(false)
        }
    }

    updatePlayingCardState(isPlaying) {
        if (this.currentPlayingCard) {
            const status = this.currentPlayingCard.querySelector('[data-phrase-target="playStatus"]')
            status.textContent = isPlaying ? "Playing..." : "Click to play"
            this.currentPlayingCard.classList.toggle('bg-green-100', isPlaying)
        }
    }

    async fetchAndPlayAudio(audioUrl, card, playStatus) {
        try {
            const response = await fetch(audioUrl, {
                credentials: 'same-origin',
                headers: {
                    'Accept': 'audio/mpeg,audio/*;q=0.8,*/*;q=0.5',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                }
            })

            if (!response.ok) throw new Error('Failed to fetch audio')

            const blob = await response.blob()
            const blobUrl = URL.createObjectURL(blob)

            const audio = new Audio(blobUrl)

            // Set up audio event handlers
            audio.onended = () => this.handleAudioEnd(card, playStatus, blobUrl)
            audio.onerror = () => this.handleAudioError(blobUrl)

            // Play the audio
            await audio.play()

            // Update state
            this.currentAudio = audio
            this.currentPlayingCard = card
            this.updatePlayingCardState(true)

            console.log("Audio playing successfully")
        } catch (error) {
            console.error("Error in fetchAndPlayAudio:", error)
            throw error
        }
    }

    handleAudioEnd(card, playStatus, blobUrl) {
        playStatus.textContent = "Click to play"
        card.classList.remove('bg-green-100')
        this.resetPlaybackState()
        URL.revokeObjectURL(blobUrl)
    }

    handleAudioError(blobUrl) {
        console.error("Audio playback error")
        this.resetPlaybackState()
        URL.revokeObjectURL(blobUrl)
    }

    resetPlaybackState() {
        this.currentAudio = null
        this.currentPlayingCard = null
    }

    // Sharing functionality
    async share(event) {
        event.preventDefault()
        const button = event.currentTarget
        const phraseId = button.dataset.phraseId
        const text = button.dataset.phraseText

        try {
            const audioData = await this.fetchAudioMetadata(phraseId)
            await this.handleSharing(phraseId, text, audioData)
        } catch (error) {
            console.error('Error sharing audio:', error)
            alert('Sorry, there was a problem sharing the audio. Please try again.')
        }
    }

    async fetchAudioMetadata(phraseId) {
        const response = await fetch(`/phrases/${phraseId}/audio`, {
            headers: {
                'Accept': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            }
        })
        if (!response.ok) throw new Error('Failed to fetch audio metadata')
        return response.json()
    }

    async handleSharing(phraseId, text, audioData) {
        if (navigator.share) {
            try {
                const file = await this.prepareAudioFile(phraseId, audioData)
                await navigator.share({ text, files: [file] })
            } catch (shareError) {
                if (shareError.name !== 'AbortError') {
                    this.downloadAudio(audioData.url, audioData.filename)
                }
            }
        } else {
            this.downloadAudio(audioData.url, audioData.filename)
        }
    }

    async prepareAudioFile(phraseId, audioData) {
        const response = await fetch(`/phrases/${phraseId}/audio`, {
            headers: { 'Accept': 'application/octet-stream' }
        })
        if (!response.ok) throw new Error('Failed to fetch audio file')

        const blob = await response.blob()
        return new File([blob], audioData.filename, {
            type: audioData.content_type
        })
    }

    // Utility methods
    stopPropagation(event) {
        event.stopPropagation()
    }

    downloadAudio(url, filename) {
        const link = document.createElement('a')
        link.href = url
        link.download = filename
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
    }

    // Category management
    toggleNewCategory(event) {
        const selectedValue = event.target.value
        const newCategoryField = this.newCategoryTarget

        newCategoryField.style.display = selectedValue === "" ? "block" : "none"
        if (selectedValue !== "") {
            newCategoryField.value = ""
        }
    }

    // Form submission
    async createPhrase(event) {
        event.preventDefault()
        const form = event.target
        const formData = new FormData(form)

        // Handle new category
        const newCategory = formData.get('phrase[new_category]')
        if (newCategory) {
            formData.set('phrase[category]', newCategory)
        }

        try {
            const response = await fetch(form.action, {
                method: form.method,
                body: formData,
                headers: {
                    "Accept": "text/vnd.turbo-stream.html"
                }
            })

            if (!response.ok) throw new Error('Failed to create phrase')

            const html = await response.text()
            Turbo.renderStreamMessage(html)
            form.reset()
            this.newCategoryTarget.style.display = "none"
        } catch (error) {
            console.error("Error creating phrase:", error)
            alert("Error creating phrase. Please try again.")
        }
    }

    // Drag and drop handling
    async handleDragEnd(event) {
        const phraseId = event.item.id.split('_')[1]
        const newCategory = event.to.dataset.category
        event.to.style.maxHeight = `${event.to.scrollHeight}px`

        try {
            const response = await fetch(`/phrases/${phraseId}`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ phrase: { category: newCategory } })
            })

            if (!response.ok) throw new Error('Failed to update phrase category')
        } catch (error) {
            console.error('Error updating category:', error)
            alert('Failed to update category. Please try again.')
        }
    }

    // Cleanup
    disconnect() {
        if (this.currentAudio) {
            this.currentAudio.pause()
            this.currentAudio = null
        }
        // Clean up any remaining blob URLs
        if (this.audioCache) {
            this.audioCache.forEach(url => URL.revokeObjectURL(url))
            this.audioCache.clear()
        }
    }
}

