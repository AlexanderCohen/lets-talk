import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "suggestions"]
    static values = { phraseSuggestionUrl: String }

    connect() {
        this.timeout = null
        this.debounceTime = 1500 // 1.5 seconds
        console.log("Phrase suggestion controller connected")
    }

    typing() {
        console.log("Typing event received")
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => this.fetchSuggestions(), this.debounceTime)
    }

    async fetchSuggestions() {
        console.log("Fetching suggestions")
        console.log(this.phraseSuggestionUrlValue)
        const inputValue = this.inputTarget.value
        if (inputValue.length === 0) {
            this.suggestionsTarget.innerHTML = "" // Clear suggestions if input is empty
            return
        }

        try {
            const response = await fetch('/fetch_suggestions', { // Updated URL path
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ phrase: inputValue })
            })
            console.log(response)
            if (response.ok) {
                const html = await response.text()
                this.suggestionsTarget.innerHTML = html
            }
        } catch (error) {
            console.error('Error fetching suggestions:', error)
        }
    }

    selectSuggestion(event) {
        const selectedText = event.target.dataset.suggestion
        this.inputTarget.value = selectedText
        this.suggestionsTarget.innerHTML = "" // Clear suggestions after selection
    }
}