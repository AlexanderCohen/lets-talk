import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["playButton", "form", "phrasesList", "playStatus", "newCategory"]

    connect() {
        console.log("Phrases controller connected")
        this.currentAudio = null
        this.currentPlayingCard = null
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
            const audio = new Audio(audioUrl)
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
                }
            }).catch(error => {
                console.error("Error playing audio:", error)
                alert("Error playing audio. Please try again.")
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

    disconnect() {
        if (this.currentAudio) {
            this.currentAudio.pause()
            this.currentAudio = null
        }
    }
}