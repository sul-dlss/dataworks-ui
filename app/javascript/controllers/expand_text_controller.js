import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggle"]
  static values = {
    moreLabel: { type: String, default: "more" },
    lessLabel: { type: String, default: "less" }
  }

  connect() {
    if (this.contentTarget.scrollHeight <= this.contentTarget.clientHeight) {
      this.contentTarget.classList.remove("expand-text--collapsed")
      this.toggleTarget.hidden = true
    } else {
      this.toggleTarget.textContent = this.moreLabelValue
    }
  }

  toggle() {
    const collapsed = this.contentTarget.classList.toggle("expand-text--collapsed")
    this.toggleTarget.textContent = collapsed ? this.moreLabelValue : this.lessLabelValue
  }
}
