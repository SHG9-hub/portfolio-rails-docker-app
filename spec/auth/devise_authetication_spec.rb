require 'rails_helper'

RSpec.describe "認証について", type: :system do
    before do
        driven_by :rack_test
    end

    it "未ログインのユーザーは認証が必要なページにアクセスできないこと"do
    # root_pathは既にログインページなので、attendances_pathに直接アクセスしてテスト
    visit attendances_path

    expect(current_path).to eq(new_user_session_path)
    end

    it "root_pathはログインページにリダイレクトすること" do
    visit root_path

    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content("ログイン")
    end
end