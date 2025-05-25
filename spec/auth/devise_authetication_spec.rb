require 'rails_helper'

RSpec.describe "認証について", type: :system do
    before do
        driven_by :rack_test
    end

    it "未ログインのユーザーは認証が必要なページにアクセスできないこと"do
    visit root_path

    expect(current_path).to eq(new_user_session_path)

    end
end