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
                // Not sure why, but after an hour or so, we get an error when trying to play the file.
                // Suspect creating a new Audio(audioUrl) for each link on page load may resolve the issue.
                alert("Error playing audio. Please try refreshing the page then trying again.")
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
        event.preventDefault();
        const button = event.currentTarget;
        const text = button.dataset.phraseText;
        let audioUrl = button.dataset.phraseAudio;

        console.log('Share function called');
        console.log('Text to share:', text);
        console.log('Original Audio URL:', audioUrl);

        // If the URL is relative, make it absolute
        // This will route through the production site when in development and test.
        if (audioUrl.startsWith('/')) {
            audioUrl = `https://lets-talk-together.com${audioUrl}`;
        }

        console.log('Final Audio URL:', audioUrl);

        try {
            console.log('Attempting to fetch audio file...');
            const response = await fetch(audioUrl);
            console.log('Fetch response:', response);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const blob = await response.blob();
            console.log('Audio blob created:', blob);

            const audioFile = new File([blob], "audio.mp3", { type: "audio/mpeg" });
            console.log('Audio File object created:', audioFile);

            if (navigator.share) {
                console.log('Web Share API is supported');
                try {
                    await navigator.share({
                        text: text,
                        files: [audioFile]
                    });
                    console.log('Shared successfully');
                } catch (shareError) {
                    console.error('Error during share:', shareError);
                    if (shareError.name === 'AbortError') {
                        console.log('User cancelled the share operation');
                    } else {
                        throw shareError;
                    }
                }
            } else {
                console.log('Web Share API is not supported, falling back to download');
                const url = URL.createObjectURL(blob);
                console.log('Blob URL created:', url);
                const a = document.createElement('a');
                a.style.display = 'none';
                a.href = url;
                a.download = 'audio.mp3';
                document.body.appendChild(a);
                a.click();
                console.log('Download initiated');
                URL.revokeObjectURL(url);
            }
        } catch (error) {
            console.error('Error in share function:', error);
            console.error('Error details:', error.message);
            alert("Error sharing the audio file. Please check the console for details.");
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
            // Optionally, revert the DOM change or show an error message
        })
    }
}