import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggle", "moreControl", "lessControl"]
  static values = {
    moreLabel: { type: String, default: "more" },
    lessLabel: { type: String, default: "less" }
  }

  connect() {
    if (this.contentTarget.scrollHeight <= this.contentTarget.clientHeight) {
      this.contentTarget.classList.remove("expand-text--collapsed")
      this.toggleTarget.hidden = true
    } else {
      this.render(true)
    }
  }

  toggle() {
    const collapsed = this.contentTarget.classList.toggle("expand-text--collapsed")
    this.render(collapsed)
  }

  // Show the control matching the current state. When the markup provides
  // more/less controls, swap which is visible;
  // otherwise fall back to setting the toggle's text label.
  render(collapsed) {
    if (this.hasMoreControlTarget && this.hasLessControlTarget) {
      this.moreControlTarget.hidden = !collapsed
      this.lessControlTarget.hidden = collapsed
    } else {
      this.toggleTarget.textContent = collapsed ? this.moreLabelValue : this.lessLabelValue
    }
  }
}
