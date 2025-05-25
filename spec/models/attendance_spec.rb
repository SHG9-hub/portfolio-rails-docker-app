require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe "アソシエーション" do
    it "userに属している" do
      attendance = Attendance.new
      expect(attendance).to respond_to(:user)
    end
  end

  describe "バリデーション" do
    it "userが必須であること" do
      attendance = Attendance.new
      expect(attendance).to_not be_valid
      expect(attendance.errors[:user]).to include("must exist")
    end
  end

  describe "出勤記録" do
    let(:user) { User.create!(email: "test@example.com", password: "password") }
    
    it "出勤時間が記録される" do
      attendance = Attendance.create!(user: user, check_in: Time.current)
      expect(attendance.check_in).to be_present
    end
  end

  describe 'データベースカラム' do
    it "check_inカラムを持つこと" do
      expect(Attendance.column_names).to include("check_in")
    end

    it "check_outカラムを持つこと" do
      expect(Attendance.column_names).to include("check_out")
    end

    it "user_idカラムを持つこと" do
      expect(Attendance.column_names).to include("user_id")
    end
  end
end
