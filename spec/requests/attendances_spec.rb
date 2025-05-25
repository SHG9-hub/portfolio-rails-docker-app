require 'rails_helper'

RSpec.describe "Attendances", type: :request do
  let(:user) { User.create!(email: "test@example.com", password: "password") }

  describe "GET /attendances (root_path)" do
    context "認証されていないユーザーの場合" do
      it "ログインページにリダイレクトされること" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "attendances_pathにアクセスできないこと" do
        get attendances_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "認証済みユーザーの場合" do
      before do
        sign_in user
      end

      it "root_pathに正常にアクセスできること" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "attendances_pathに正常にアクセスできること" do
        get attendances_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "認証制御" do
    it "authenticate_user!が設定されていること" do
      get attendances_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
