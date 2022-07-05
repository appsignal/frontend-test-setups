import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    throw new Error("This is an error")
  }
}
