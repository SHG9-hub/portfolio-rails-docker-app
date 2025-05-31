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

  describe '#working_hours' do
    let(:user) { User.create!(email: "test@example.com", password: "password") }
    
    context '出勤時間と退勤時間が両方記録されている場合' do
      it '正確な勤務時間を時間単位で返す' do
        check_in_time = Time.zone.parse('2025-01-15 09:00:00')
        check_out_time = Time.zone.parse('2025-01-15 18:00:00')
        attendance = Attendance.create!(
          user: user, 
          check_in: check_in_time, 
          check_out: check_out_time
        )
        
        expect(attendance.working_hours).to eq(9.0)
      end
      
      it '30分の勤務時間を正しく計算する' do
        check_in_time = Time.zone.parse('2025-01-15 09:00:00')
        check_out_time = Time.zone.parse('2025-01-15 09:30:00')
        attendance = Attendance.create!(
          user: user, 
          check_in: check_in_time, 
          check_out: check_out_time
        )
        
        expect(attendance.working_hours).to eq(0.5)
      end
      
      it '8時間45分の勤務時間を正しく計算する' do
        check_in_time = Time.zone.parse('2025-01-15 09:00:00')
        check_out_time = Time.zone.parse('2025-01-15 17:45:00')
        attendance = Attendance.create!(
          user: user, 
          check_in: check_in_time, 
          check_out: check_out_time
        )
        
        expect(attendance.working_hours).to eq(8.75)
      end
      
      it '結果が小数点以下2桁に丸められる' do
        check_in_time = Time.zone.parse('2025-01-15 09:00:00')
        check_out_time = Time.zone.parse('2025-01-15 17:20:00') # 8時間20分 = 8.333...時間
        attendance = Attendance.create!(
          user: user, 
          check_in: check_in_time, 
          check_out: check_out_time
        )
        
        expect(attendance.working_hours).to eq(8.33)
      end
    end
    
    context '出勤時間のみ記録されている場合' do
      it 'nilを返す' do
        attendance = Attendance.create!(
          user: user, 
          check_in: Time.zone.parse('2025-01-15 09:00:00'), 
          check_out: nil
        )
        
        expect(attendance.working_hours).to be_nil
      end
    end
    
    context '退勤時間のみ記録されている場合' do
      it 'nilを返す' do
        attendance = Attendance.create!(
          user: user, 
          check_in: nil, 
          check_out: Time.zone.parse('2025-01-15 18:00:00')
        )
        
        expect(attendance.working_hours).to be_nil
      end
    end
    
    context '出勤時間も退勤時間も記録されていない場合' do
      it 'nilを返す' do
        attendance = Attendance.create!(
          user: user, 
          check_in: nil, 
          check_out: nil
        )
        
        expect(attendance.working_hours).to be_nil
      end
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
