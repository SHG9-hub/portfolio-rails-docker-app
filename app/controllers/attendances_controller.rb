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

    def edit
        @attendance = current_user.attendances.find(params[:id])
    end

    def update
        @attendance = current_user.attendances.find(params[:id])
        if @attendance.update(attendance_params.merge(check_out: Time.current))
            redirect_to attendances_path
        else
            flash.now[:alert] = @attendance.errors.full_messages.join(', ')
            render :edit, status: :unprocessable_entity
        end
    end

    private

    def attendance_params
        params.require(:attendance).permit(:check_in, :check_out)
    end
end
