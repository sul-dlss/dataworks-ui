import { Controller } from "@hotwired/stimulus"

// Collapses a list to its first `maxRows` rows, revealing the overflow behind a toggle.
//
// If the markup supplies more/less controls, they are swapped on toggle.
// Otherwise a "+N" button is built and appended to the list.
export default class extends Controller {
  static targets = ["item", "toggle", "moreControl", "lessControl"]
  static values = {
    maxRows: { type: Number, default: 2 }
  }

  connect() {
    requestAnimationFrame(() => this.#truncate())
  }

  #truncate() {
    const items = this.itemTargets
    if (items.length === 0) return

    const rowTops = []
    let hiddenFromIndex = null

    for (const [index, item] of items.entries()) {
      const top = item.offsetTop
      if (!rowTops.includes(top)) rowTops.push(top)
      if (rowTops.length > this.maxRowsValue) {
        hiddenFromIndex = index
        break
      }
    }

    if (hiddenFromIndex === null) return

    this.hiddenItems = items.slice(hiddenFromIndex)
    this.hiddenItems.forEach(item => { item.hidden = true })

    if (this.hasToggleTarget) {
      this.toggleTarget.hidden = false
      this.#setCollapsed(true)
    } else {
      this.element.appendChild(this.#buildToggle(this.hiddenItems, true))
    }
  }

  // Toggle for markup-supplied more/less controls.
  toggle() {
    this.#setCollapsed(!this.collapsed)
  }

  #setCollapsed(collapsed) {
    this.collapsed = collapsed
    this.hiddenItems.forEach(item => { item.hidden = collapsed })
    this.moreControlTarget.hidden = !collapsed
    this.lessControlTarget.hidden = collapsed
  }

  // "+N" toggle for lists without markup controls (the pill list,
  // where the hidden count is only known after measuring rows).
  #buildToggle(hiddenItems, collapsed) {
    const li = document.createElement("li")
    const button = document.createElement("button")
    button.className = "expand-items__toggle btn btn-link p-0"
    button.textContent = collapsed ? `+${hiddenItems.length} subjects` : "less"
    button.addEventListener("click", () => {
      hiddenItems.forEach(item => item.hidden = !collapsed)
      li.replaceWith(this.#buildToggle(hiddenItems, !collapsed))
    }, { once: true })

    li.appendChild(button)
    return li
  }
}
