require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  test "must have name and position" do
    employee = Employee.new(base_salary: 1)

    assert_not employee.valid?
    assert_includes employee.errors[:name], "can't be blank"
    assert_includes employee.errors[:position], "can't be blank"
  end

  test "must have positive salary" do
    employee = Employee.new(name: "No Salary", position: "Tester", base_salary: 0)

    assert_not employee.valid?
    assert_includes employee.errors[:base_salary], "must be greater than 0"
  end

  test "calculate monthly working days and overtime" do
    employee = employees(:one)
    month = Date.new(2026, 3, 1)

    assert_equal 2, employee.working_days(month)
    assert_equal 1.0, employee.ot_hours(month)
    assert_equal 125.0, employee.ot_pay(month).to_f
  end

  test "calculate tax with progressive rate from assignment example" do
    employee = Employee.create!(name: "Tax Sample", position: "QA", base_salary: 54_000)
    month = Date.new(2026, 3, 1)

    assert_equal 54_000.0, employee.gross_pay(month).to_f
    assert_equal 1_400.0, employee.tax(month).to_f
    assert_equal 52_600.0, employee.net_pay(month).to_f
  end

  test "monthly scope only includes selected month" do
    employee = employees(:one)
    employee.attendances.create!(
      work_date: Date.new(2026, 4, 1),
      check_in_at: Time.zone.parse("2026-04-01 09:00"),
      check_out_at: Time.zone.parse("2026-04-01 17:00")
    )

    assert_equal 2, employee.monthly_attendances(Date.new(2026, 3, 1)).count
    assert_equal 1, employee.monthly_attendances(Date.new(2026, 4, 1)).count
  end

  test "calculate tax at progressive boundaries" do
    at_30k = Employee.create!(name: "At 30k", position: "QA", base_salary: 30_000)
    at_30001 = Employee.create!(name: "At 30001", position: "QA", base_salary: 30_001)
    at_50k = Employee.create!(name: "At 50k", position: "QA", base_salary: 50_000)
    at_50001 = Employee.create!(name: "At 50001", position: "QA", base_salary: 50_001)
    month = Date.new(2026, 3, 1)

    assert_equal 0.0, at_30k.tax(month).to_f
    assert_equal 0.05, at_30001.tax(month).to_f
    assert_equal 1_000.0, at_50k.tax(month).to_f
    assert_equal 1_000.1, at_50001.tax(month).to_f
  end

  test "overtime pay can push income to next tax bracket" do
    employee = Employee.create!(name: "OT Bracket", position: "QA", base_salary: 48_000)
    month = Date.new(2026, 3, 1)
    employee.attendances.create!(
      work_date: Date.new(2026, 3, 10),
      check_in_at: Time.zone.parse("2026-03-10 00:00"),
      check_out_at: Time.zone.parse("2026-03-10 19:00")
    )

    assert_equal 11.0, employee.ot_hours(month).to_f
    assert_equal 2_200.0, employee.ot_pay(month).to_f
    assert_equal 50_200.0, employee.gross_pay(month).to_f
    assert_equal 1_020.0, employee.tax(month).to_f
    assert_equal 49_180.0, employee.net_pay(month).to_f
  end
end
