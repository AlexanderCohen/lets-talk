import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    play(event) {
        const audioUrl = event.currentTarget.dataset.audioUrl
        if (audioUrl) {
            const audio = new Audio(audioUrl)
            audio.play()
        } else {
            alert("Audio not available.")
        }
    }
}