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
      expect(attendance.errors[:user]).to be_present
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

  describe 'スコープとクラスメソッド' do
    let(:user) { User.create!(email: "test@example.com", password: "password") }
    let!(:attendance1) do
      Attendance.create!(user: user, check_in: Time.zone.parse('2025-01-10 09:00:00'), check_out: Time.zone.parse('2025-01-10 18:00:00'))
    end
    let!(:attendance2) do
      Attendance.create!(user: user, check_in: Time.zone.parse('2025-01-15 09:00:00'), check_out: Time.zone.parse('2025-01-15 17:30:00'))
    end
    let!(:attendance3) do
      Attendance.create!(user: user, check_in: Time.zone.parse('2025-02-01 09:00:00'), check_out: Time.zone.parse('2025-02-01 18:00:00'))
    end
    let!(:attendance4) do
      Attendance.create!(user: user, check_in: Time.zone.parse('2024-01-10 09:00:00'), check_out: Time.zone.parse('2024-01-10 18:00:00'))
    end
    let!(:attendance5) do # 退勤なしのレコード
      Attendance.create!(user: user, check_in: Time.zone.parse('2025-01-20 09:00:00'), check_out: nil)
    end

    describe '.month_record' do
      context '指定した年月の勤怠記録がある場合' do
        it '該当年月の記録のみをcheck_inの昇順で返す' do
          records = Attendance.month_record(2025, 1)
          expect(records.count).to eq(3)
          expect(records).to include(attendance1, attendance2, attendance5)
          expect(records).not_to include(attendance3, attendance4)
          expect(records.first).to eq(attendance1) # check_inの昇順
        end
      end

      context '指定した年月の勤怠記録がない場合' do
        it '空のActiveRecord::Relationを返す' do
          records = Attendance.month_record(2026, 1)
          expect(records).to be_empty
        end
      end

      context '年が整数で渡されない場合' do
        it '文字列で渡されても正しくフィルタリングする' do
          records = Attendance.month_record('2025', 1)
          expect(records.count).to eq(3)
          expect(records).to include(attendance1, attendance2, attendance5)
        end
      end

      context '月が整数で渡されない場合' do
        it '文字列で渡されても正しくフィルタリングする' do
          records = Attendance.month_record(2025, '1')
          expect(records.count).to eq(3)
          expect(records).to include(attendance1, attendance2, attendance5)
        end
      end
    end

    describe '.total_working_hours' do
      it '指定した勤怠記録の合計勤務時間を計算して返す' do
        # attendance1: 9時間, attendance2: 8.5時間, attendance5: 0時間 (nil -> 0)
        attendances = Attendance.where(id: [attendance1.id, attendance2.id, attendance5.id])
        expect(attendances.total_working_hours).to eq(9.0 + 8.5 + 0.0)
      end

      it '空のコレクションの場合は0.0を返す' do
        expect(Attendance.none.total_working_hours).to eq(0.0)
      end

      it '全ての記録が退勤なしの場合、0.0を返す' do
        attendances_no_checkout = Attendance.where(id: [attendance5.id])
        expect(attendances_no_checkout.total_working_hours).to eq(0.0)
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
