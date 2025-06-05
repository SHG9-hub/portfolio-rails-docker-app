// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// フラッシュメッセージの自動削除
document.addEventListener('DOMContentLoaded', function() {
  const flashMessages = document.querySelectorAll('.flash-notice, .flash-alert');
  
  flashMessages.forEach(function(message) {
    // 5秒後にフェードアウト
    setTimeout(function() {
      message.style.transition = 'opacity 0.5s ease-out, transform 0.5s ease-out';
      message.style.opacity = '0';
      message.style.transform = 'translateX(100%)';
      
      // フェードアウト完了後に要素を削除
      setTimeout(function() {
        message.remove();
      }, 500);
    }, 5000);
    
    // クリックで即座に削除
    message.addEventListener('click', function() {
      message.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out';
      message.style.opacity = '0';
      message.style.transform = 'translateX(100%)';
      
      setTimeout(function() {
        message.remove();
      }, 300);
    });
  });
});

// Turbo向けの対応
document.addEventListener('turbo:load', function() {
  const flashMessages = document.querySelectorAll('.flash-notice, .flash-alert');
  
  flashMessages.forEach(function(message) {
    setTimeout(function() {
      message.style.transition = 'opacity 0.5s ease-out, transform 0.5s ease-out';
      message.style.opacity = '0';
      message.style.transform = 'translateX(100%)';
      
      setTimeout(function() {
        message.remove();
      }, 500);
    }, 5000);
    
    message.addEventListener('click', function() {
      message.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out';
      message.style.opacity = '0';
      message.style.transform = 'translateX(100%)';
      
      setTimeout(function() {
        message.remove();
      }, 300);
    });
  });
});
