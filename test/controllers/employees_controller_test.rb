require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @employee = employees(:one)
  end

  test "should get index" do
    get employees_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_url
    assert_response :success
  end

  test "should create employee" do
    assert_difference("Employee.count") do
      post employees_url, params: { employee: { base_salary: @employee.base_salary, name: @employee.name, position: @employee.position } }
    end

    assert_redirected_to employee_url(Employee.last)
  end

  test "should show employee" do
    get employee_url(@employee)
    assert_response :success
  end

  test "show page displays payroll summary values" do
    get employee_url(@employee, month: "2026-03")

    assert_response :success
    assert_includes response.body, "Working Days"
    assert_includes response.body, "OT Hours"
    assert_includes response.body, "OT Pay"
    assert_includes response.body, "Tax Deductions"
    assert_includes response.body, "Net Pay Received"
    assert_match(/OT Pay.*125\.00/m, response.body)
    assert_match(/Tax Deductions.*6\.25/m, response.body)
    assert_match(/Net Pay Received.*30,118\.75/m, response.body)
  end

  test "show page initializes attendance defaults at 09:00 and 17:00" do
    travel_to Time.zone.parse("2026-03-09 04:02:00") do
      get employee_url(@employee, month: "2026-03")

      assert_response :success
      assert_includes response.body, "id=\"attendance_work_date\""
      assert_includes response.body, "name=\"attendance[check_in_at]\""
      assert_includes response.body, "name=\"attendance[check_out_at]\""
      assert_includes response.body, "value=\"2026-03-09\""
      assert_includes response.body, "value=\"2026-03-09T09:00\""
      assert_includes response.body, "value=\"2026-03-09T17:00\""
    end
  end

  test "should get edit" do
    get edit_employee_url(@employee)
    assert_response :success
  end

  test "should update employee" do
    patch employee_url(@employee), params: { employee: { base_salary: @employee.base_salary, name: @employee.name, position: @employee.position } }
    assert_redirected_to employee_url(@employee)
  end

  test "should destroy employee" do
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end

    assert_redirected_to employees_url
  end
end
