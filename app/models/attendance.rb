class Attendance < ApplicationRecord
  belongs_to :user

  # 勤務時間を計算するメソッド (時間単位で返す)
  def working_hours
    if check_in && check_out
      ((check_out - check_in) / 3600.0).round(2) # 秒を時間に変換し、小数点以下2桁に丸める
    else
      nil # 退勤時間がまだ記録されていない場合はnilを返す
    end
  end
end
