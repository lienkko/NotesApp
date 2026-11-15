import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "customField"]

  toggleCustomField() {
    const isCustomCategory = this.selectTarget.value === "new"
    this.customFieldTarget.hidden = !isCustomCategory
  }
}
