import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "date", "time" ]

  connect() {
    this.dateFormatter = new Intl.DateTimeFormat("th-TH-u-ca-gregory", {
      weekday: "long",
      day: "numeric",
      month: "long",
      year: "numeric"
    })

    this.timeFormatter = new Intl.DateTimeFormat("th-TH", {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: false
    })

    this.update()
    this.timer = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  update() {
    const now = new Date()
    this.dateTarget.textContent = this.dateFormatter.format(now)
    this.timeTarget.textContent = this.timeFormatter.format(now)
  }
}
