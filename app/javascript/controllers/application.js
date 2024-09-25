import { Application } from "@hotwired/stimulus"
import "@fortawesome/fontawesome-free/js/all.js"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }

import Alpine from "alpinejs"
window.Alpine = Alpine
Alpine.start()