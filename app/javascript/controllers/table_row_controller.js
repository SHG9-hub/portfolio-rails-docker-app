import { Controller } from "@hotwired/stimulus"

// テーブル行のクリック機能を管理するStimulusコントローラー
export default class extends Controller {
  static values = { href: String }

  // 行がクリックされた時の処理
  click() {
    if (this.hasHrefValue && this.hrefValue) {
      window.location.href = this.hrefValue
    }
  }
} 