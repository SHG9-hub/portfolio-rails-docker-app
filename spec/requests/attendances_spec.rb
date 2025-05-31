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

  describe "PATCH /attendances/:id" do
    let(:check_in_time) { Time.zone.parse('2025-01-01 09:00:00') }
    let!(:attendance) { Attendance.create!(user: user, check_in: check_in_time, check_out: nil) }

    it "勤怠レコードのcheck_outが設定されること" do
      patch "/attendances/#{attendance.id}", params: { attendance: { check_out: '' } }
      attendance.reload
      expect(attendance.check_out).to be_present
      expect(attendance.check_out).to be_within(1.minute).of(Time.current)
    end

    it "attendances_pathにリダイレクトされること" do
      patch "/attendances/#{attendance.id}", params: { attendance: { check_out: '' } }
      expect(response).to redirect_to(attendances_path)
    end
  end

  describe "DELETE /attendances/:id" do
    let!(:attendance) { Attendance.create!(user: user, check_in: Time.current, check_out: Time.current + 8.hours) }

    it "勤怠記録が削除される" do
      expect {
        delete attendance_path(attendance)
      }.to change(Attendance, :count).by(-1)
    end

    it "削除後にattendances_pathにリダイレクトされる" do
      delete attendance_path(attendance)
      expect(response).to redirect_to(attendances_path)
    end

    it "削除された記録が存在しないことを確認" do
      delete attendance_path(attendance)
      expect { Attendance.find(attendance.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
