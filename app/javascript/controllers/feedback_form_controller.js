import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["agent", "viewport", "lastSearch"]

  connect() {
    this.setHiddenFieldValues()
  }

  setHiddenFieldValues() {
    this.agentTarget.value = navigator.userAgent
    this.viewportTarget.value = "width:" + window.innerWidth + " height:" + innerHeight
    const lastSearchValue = this.lastSearch()
    if (lastSearchValue != null) {
      this.lastSearchTarget.value = lastSearchValue
    }
  }

  lastSearch() {
    const backToResults = document.querySelector(".back-to-results")
    if (backToResults == null) return null
    return backToResults.href
  }

  closeModal(event) {
    if (event.detail.success) document.querySelector('.blacklight-modal-close')?.click()
  }
}
