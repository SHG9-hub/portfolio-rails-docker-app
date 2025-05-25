require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it "メールアドレスがない場合は無効であること" do
      user = User.new(email: nil, password: "password")
      expect(user).to_not be_valid
    end

    it "メールアドレスがある場合は有効であること" do
      user = User.new(email: "test@example.com", password: "password")
      expect(user).to be_valid
    end

    it "重複するメールアドレスは無効であること" do
      User.create!(email: "test@example.com", password: "password")
      user = User.new(email: "test@example.com", password: "password")
      expect(user).to_not be_valid
    end
  end

  describe 'アソシエーション' do
    it "attendancesアソシエーションを持つこと" do
      user = User.new
      expect(user).to respond_to(:attendances)
    end
  end

  describe 'Devise設定' do
    it "メールアドレスでログインできること" do
      user = User.create!(email: "test@example.com", password: "password")
      expect(user.valid_password?("password")).to be true
    end

    it "間違ったパスワードでは認証に失敗すること" do
      user = User.create!(email: "test@example.com", password: "password")
      expect(user.valid_password?("wrongpassword")).to be false
    end
  end
end
