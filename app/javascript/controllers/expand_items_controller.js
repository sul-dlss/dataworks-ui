import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    maxRows: { type: Number, default: 2 }
  }

  connect() {
    requestAnimationFrame(() => this.#truncate())
  }

  #truncate() {
    const items = Array.from(this.element.children)
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

    const hiddenItems = items.slice(hiddenFromIndex)
    hiddenItems.forEach(item => item.hidden = true)

    this.element.appendChild(this.#buildToggle(hiddenItems, true))
  }

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
