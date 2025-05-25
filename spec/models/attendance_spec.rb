require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe 'アソシエーション' do
    it "userに属すること" do
      attendance = Attendance.new
      expect(attendance).to respond_to(:user)
    end

    it "userが必須であること" do
      attendance = Attendance.new
      expect(attendance).to_not be_valid
      expect(attendance.errors[:user]).to include("must exist")
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
