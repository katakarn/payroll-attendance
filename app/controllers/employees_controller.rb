class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]

  # GET /employees or /employees.json
  def index
    @employees = Employee.all
  end

  # GET /employees/1 or /employees/1.json
  def show
    @selected_month = selected_month
    default_work_date = Date.current
    @attendance = @employee.attendances.new(
      work_date: default_work_date,
      check_in_at: Time.zone.local(default_work_date.year, default_work_date.month, default_work_date.day, 9, 0, 0),
      check_out_at: Time.zone.local(default_work_date.year, default_work_date.month, default_work_date.day, 17, 0, 0)
    )
    set_show_page_data
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees or /employees.json
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: "Employee was successfully created." }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1 or /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: "Employee was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1 or /employees/1.json
  def destroy
    @employee.destroy!

    respond_to do |format|
      format.html { redirect_to employees_path, notice: "Employee was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def employee_params
      params.expect(employee: [ :name, :position, :base_salary ])
    end

    def selected_month
      Date.strptime(params[:month], "%Y-%m").beginning_of_month
    rescue ArgumentError, TypeError
      Date.current.beginning_of_month
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
