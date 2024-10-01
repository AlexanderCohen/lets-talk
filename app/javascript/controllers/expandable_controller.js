/**
 * This Stimulus controller manages the expand/collapse functionality for an element.
 * 
 * Usage:
 * 1. Add `data-controller="expandable"` to the parent element.
 * 2. Add `data-expandable-target="content"` to the content element that should be expanded/collapsed.
 * 3. Add `data-expandable-target="icon"` to the icon element that should rotate on expand/collapse.
 * 4. Optionally, add `data-expandable-default-expanded-value="true"` to the parent element to have it expanded by default.
 * 5. Add `data-action="click->expandable#toggle"` to the element that should trigger the expand/collapse on click.
 */

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { defaultExpanded: Boolean }

  connect() {
    this.defaultExpandedValue ? this.expand() : this.collapse()
  }

  toggle() {
    this.expanded ? this.collapse() : this.expand()
  }

  expand() {
    this.contentTarget.style.maxHeight = `${this.contentTarget.scrollHeight}px`
    this.iconTarget.style.transform = "rotate(180deg)"
    this.expanded = true
  }

  collapse() {
    this.contentTarget.style.maxHeight = "0px"
    this.iconTarget.style.transform = "rotate(0deg)"
    this.expanded = false
  }
}