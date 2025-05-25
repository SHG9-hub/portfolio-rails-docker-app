class AttendancesController < ApplicationController
    before_action :authenticate_user!
    def index
        @attendances = current_user.attendances.order(check_in: :desc)
    end

    def new
        @attendance = Attendance.new
    end
    
    def create
        @attendance = current_user.attendances.build(attendance_params)
        if @attendance.save
          redirect_to attendances_path
        else
          flash.now[:alert] = @attendance.errors.full_messages.join(', ')
          render :new, status: :unprocessable_entity
        end
    end

    private

    def attendance_params
        params.require(:attendance).permit(:check_in)
    end
end
