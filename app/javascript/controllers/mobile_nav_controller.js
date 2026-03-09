import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "overlay", "backdrop", "panel" ]

  connect() {
    this.animationDuration = 200
  }

  disconnect() {
    this.unlockScroll()
    clearTimeout(this.closeTimer)
  }

  open(event) {
    if (event) event.preventDefault()
    clearTimeout(this.closeTimer)

    this.overlayTarget.classList.remove("hidden")
    this.lockScroll()

    requestAnimationFrame(() => {
      this.backdropTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("-translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
    })
  }

  close(event) {
    if (event) event.preventDefault()
    if (this.overlayTarget.classList.contains("hidden")) return

    this.backdropTarget.classList.remove("opacity-100")
    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("-translate-x-full")

    this.closeTimer = setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
      this.unlockScroll()
    }, this.animationDuration)
  }

  lockScroll() {
    document.body.classList.add("overflow-hidden")
  }

  unlockScroll() {
    document.body.classList.remove("overflow-hidden")
  }
}
