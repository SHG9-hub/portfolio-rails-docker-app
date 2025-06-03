class Attendance < ApplicationRecord
  belongs_to :user

  def working_hours
    if check_in && check_out
      ((check_out - check_in) / 3600.0).round(2)
    else
      nil 
    end
  end

  scope :month_record, ->(year, month) {
    where("EXTRACT(year FROM check_in) = ? AND EXTRACT(month FROM check_in) = ?", 
          year.to_i, 
          month.to_i)
      .order(:check_in)
  }

  def self.total_working_hours
    sum { |attendance| attendance.working_hours || 0 }
  end

end
