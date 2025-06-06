class AttendancesController < ApplicationController
    before_action :authenticate_user!
    def index
        @selected_year = params[:year].present? ? params[:year].to_i : Date.current.year
        @selected_month = params[:month].present? ? params[:month].to_i : Date.current.month
        @attendances = current_user.attendances.month_record(@selected_year, @selected_month)
    end

    def show
        @attendance = current_user.attendances.find(params[:id])
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
        if @attendance.update(attendance_params)
            redirect_to attendances_path
        else
            flash.now[:alert] = @attendance.errors.full_messages.join(', ')
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @attendance = current_user.attendances.find(params[:id])
        @attendance.destroy
        redirect_to attendances_path
    end

    private

    def attendance_params
        params.require(:attendance).permit(:check_in, :check_out)
    end
end
