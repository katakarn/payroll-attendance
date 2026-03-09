class AttendancesController < ApplicationController
  before_action :set_employee
  before_action :set_selected_month
  before_action :set_attendance, only: %i[ edit update destroy ]

  def create
    @attendance = @employee.attendances.new(attendance_params)

    if @attendance.save
      redirect_to employee_path(@employee, month: @selected_month.strftime("%Y-%m")), notice: "Attendance was successfully created."
    else
      set_show_page_data
      flash.now[:alert] = "Unable to create attendance record."
      render "employees/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @attendance.update(attendance_params)
      redirect_to employee_path(@employee, month: @selected_month.strftime("%Y-%m")), notice: "Attendance was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @attendance.destroy!
    redirect_to employee_path(@employee, month: @selected_month.strftime("%Y-%m")), notice: "Attendance was successfully deleted.", status: :see_other
  end

  private

  def set_employee
    @employee = Employee.find(params.expect(:employee_id))
  end

  def set_attendance
    @attendance = @employee.attendances.find(params.expect(:id))
  end

  def attendance_params
    params.expect(attendance: [ :work_date, :check_in_at, :check_out_at ])
  end

  def selected_month
    Date.strptime(params[:month], "%Y-%m").beginning_of_month
  rescue ArgumentError, TypeError
    Date.current.beginning_of_month
  end

  def set_selected_month
    @selected_month = selected_month
  end

  def set_show_page_data
    @attendance_records = @employee.monthly_attendances(@selected_month).order(work_date: :desc)
    @working_days = @employee.working_days(@selected_month)
    @ot_hours = @employee.ot_hours(@selected_month)
    @ot_pay = @employee.ot_pay(@selected_month)
    @tax = @employee.tax(@selected_month)
    @net_pay = @employee.net_pay(@selected_month)
  end
end
