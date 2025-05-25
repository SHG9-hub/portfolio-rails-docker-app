require 'rails_helper'

RSpec.describe "Attendances", type: :request do
  let(:user) { User.create!(email: "test@example.com", password: "password") }
  
  before do
    sign_in user
  end

  describe "GET /attendances" do
    it "勤怠履歴ページが表示される" do
      get attendances_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("勤怠履歴")
    end

    it "勤怠記録がある場合、一覧が表示される" do
      Attendance.create!(user: user, check_in: Time.current)
      get attendances_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("出勤時間")
    end

    it "勤怠記録がない場合、メッセージが表示される" do
      get attendances_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("まだ勤怠記録がありません")
    end
  end

  describe "GET /attendances/new" do
    it "打刻ページが表示される" do
      get new_attendance_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("打刻ページ")
    end
  end

  describe "POST /attendances" do
    let(:attendance_params) { { attendance: { check_in: Time.current } } }

    it "出勤記録が作成される" do
      expect {
        post attendances_path, params: attendance_params
      }.to change(Attendance, :count).by(1)
      
      expect(response).to redirect_to(attendances_path)
    end

    it "作成された記録がログインユーザーに紐づく" do
      post attendances_path, params: attendance_params
      expect(Attendance.last.user).to eq(user)
    end
  end
end
