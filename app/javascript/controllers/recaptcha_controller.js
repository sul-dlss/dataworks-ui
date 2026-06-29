import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tags"]

  async refresh(event) {
    if (!this.isRecaptchaEnabled()) return

    event.preventDefault()
    await this.execute()

    if (this.isUsingTurbo(event)) {
      Turbo.navigator.submitForm(event.target)
    } else {
      event.target.submit()
    }
  }

  isRecaptchaEnabled() {
    return this.hasTagsTarget ? true : false
  }

  isUsingTurbo(event) {
    if (event.target.getAttribute("data-turbo") === "false") {
      return false
    }
    return typeof Turbo !== "undefined"
  }

  recaptchaElement() {
    const action = this.action().replace("_", "-")
    const recaptchaId = `g-recaptcha-response-data-${action}`
    return document.getElementById(recaptchaId)
  }

  action() {
    return this.tagsTarget.getAttribute("data-recaptcha-action-value")
  }

  siteKey() {
    return this.tagsTarget.getAttribute("data-recaptcha-site-key-value")
  }

  async execute() {
    const recaptchaElement = this.recaptchaElement()
    if (!recaptchaElement || typeof grecaptcha === "undefined") return

    const response = await grecaptcha.execute(this.siteKey(), { action: this.action() })
    if (response) recaptchaElement.value = response
  }
}
