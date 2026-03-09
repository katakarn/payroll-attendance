import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "workDate", "checkIn", "checkOut" ]

  syncDate() {
    const workDate = this.workDateTarget.value
    if (!workDate) return

    this.alignDate(this.checkInTarget, workDate, "09:00")
    this.alignDate(this.checkOutTarget, workDate, "17:00")
  }

  alignDate(input, workDate, fallbackTime) {
    const currentValue = input.value
    const timePart = currentValue.includes("T") ? currentValue.split("T")[1] : fallbackTime

    input.value = `${workDate}T${timePart || fallbackTime}`
  }
}
