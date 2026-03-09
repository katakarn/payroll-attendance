require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  setup do
    @employee = employees(:one)
  end

  test "invalid when checkout is before checkin" do
    attendance = Attendance.new(
      employee: @employee,
      work_date: Date.new(2026, 3, 10),
      check_in_at: Time.zone.parse("2026-03-10 10:00"),
      check_out_at: Time.zone.parse("2026-03-10 09:59")
    )

    assert_not attendance.valid?
    assert_includes attendance.errors[:check_out_at], "must be after check in time"
  end

  test "invalid when duplicate work date for same employee" do
    attendance = Attendance.new(
      employee: @employee,
      work_date: attendances(:one).work_date,
      check_in_at: Time.zone.parse("2026-03-01 08:00"),
      check_out_at: Time.zone.parse("2026-03-01 17:00")
    )

    assert_not attendance.valid?
    assert_includes attendance.errors[:work_date], "already has a check-in for this day"
  end

  test "calculate ot hours" do
    attendance = attendances(:one)

    assert_equal 9.0, attendance.worked_hours
    assert_equal 1.0, attendance.ot_hours
  end

  test "ot hours is zero when worked hours is 8 or less" do
    eight_hours = Attendance.new(
      employee: @employee,
      work_date: Date.new(2026, 3, 11),
      check_in_at: Time.zone.parse("2026-03-11 09:00"),
      check_out_at: Time.zone.parse("2026-03-11 17:00")
    )
    seven_and_half_hours = Attendance.new(
      employee: @employee,
      work_date: Date.new(2026, 3, 12),
      check_in_at: Time.zone.parse("2026-03-12 09:00"),
      check_out_at: Time.zone.parse("2026-03-12 16:30")
    )

    assert_equal 8.0, eight_hours.worked_hours
    assert_equal 0, eight_hours.ot_hours
    assert_equal 7.5, seven_and_half_hours.worked_hours
    assert_equal 0, seven_and_half_hours.ot_hours
  end

  test "invalid when work date does not match check in date" do
    attendance = Attendance.new(
      employee: @employee,
      work_date: Date.new(2026, 3, 11),
      check_in_at: Time.zone.parse("2026-03-10 09:00"),
      check_out_at: Time.zone.parse("2026-03-10 18:00")
    )

    assert_not attendance.valid?
    assert_includes attendance.errors[:work_date], "must match check in date"
  end

  test "sets work date from check in date when work date is blank" do
    attendance = Attendance.new(
      employee: @employee,
      check_in_at: Time.zone.parse("2026-03-10 09:00"),
      check_out_at: Time.zone.parse("2026-03-10 18:00")
    )

    assert attendance.valid?
    assert_equal Date.new(2026, 3, 10), attendance.work_date
  end
end
