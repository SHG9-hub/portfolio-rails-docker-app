require 'rails_helper'

RSpec.describe AttendancesController, type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:check_in_time) { Time.zone.parse('2025-01-01 09:00:00') }
  let!(:attendance) { Attendance.create!(user: user, check_in: check_in_time, check_out: nil) }

  before do
    sign_in user
  end

  describe "PATCH /attendances/:id" do
    context "with valid parameters" do
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
  end
end 