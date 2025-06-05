import { Controller } from "@hotwired/stimulus"

// 時刻表示を管理するStimulusコントローラー
export default class extends Controller {
  static targets = ["time", "date"]
  static values = { interval: Number }

  connect() {
    this.updateClock()
    this.startInterval()
  }

  disconnect() {
    this.stopInterval()
  }

  // 現在時刻を更新
  updateClock() {
    const now = new Date()
    
    // 時刻の表示（HH:MM:SS）
    const timeString = now.toLocaleTimeString('ja-JP', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    })
    
    // 日付の表示
    const dateString = now.toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      weekday: 'long'
    })
    
    // 要素に時刻と日付を設定
    if (this.hasTimeTarget) {
      this.timeTarget.textContent = timeString
    }
    
    if (this.hasDateTarget) {
      this.dateTarget.textContent = dateString
    }
  }

  // インターバルを開始
  startInterval() {
    // デフォルトは1000ms（1秒）
    const interval = this.hasIntervalValue ? this.intervalValue : 1000
    this.timer = setInterval(() => {
      this.updateClock()
    }, interval)
  }

  // インターバルを停止
  stopInterval() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }
} 