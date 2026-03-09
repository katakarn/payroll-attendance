require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:one)
    @attendance = attendances(:one)
  end

  test "should create attendance" do
    assert_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        month: "2026-03",
        attendance: {
          work_date: "2026-03-10",
          check_in_at: "2026-03-10T09:00",
          check_out_at: "2026-03-10T18:00"
        }
      }
    end

    assert_redirected_to employee_url(@employee, month: "2026-03")
  end

  test "should not create attendance when duplicate date" do
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        month: "2026-03",
        attendance: {
          work_date: @attendance.work_date,
          check_in_at: "2026-03-01T09:00",
          check_out_at: "2026-03-01T18:00"
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should not create attendance when checkout is not after checkin" do
    assert_no_difference("Attendance.count") do
      post employee_attendances_url(@employee), params: {
        month: "2026-03",
        attendance: {
          work_date: "2026-03-10",
          check_in_at: "2026-03-10T09:00",
          check_out_at: "2026-03-10T09:00"
        }
      }
    end

    assert_response :unprocessable_content
    assert_includes response.body, "must be after check in time"
  end

  test "should update attendance" do
    patch employee_attendance_url(@employee, @attendance), params: {
      month: "2026-03",
      attendance: {
        work_date: @attendance.work_date,
        check_in_at: "2026-03-01T09:00",
        check_out_at: "2026-03-01T19:00"
      }
    }

    assert_redirected_to employee_url(@employee, month: "2026-03")
    @attendance.reload
    assert_equal 10.0, @attendance.worked_hours
  end

  test "should not update attendance when date collides with another record" do
    patch employee_attendance_url(@employee, @attendance), params: {
      month: "2026-03",
      attendance: {
        work_date: "2026-03-02",
        check_in_at: "2026-03-02T09:00",
        check_out_at: "2026-03-02T18:00"
      }
    }

    assert_response :unprocessable_content
    assert_includes response.body, "already has a check-in for this day"
    @attendance.reload
    assert_equal Date.new(2026, 3, 1), @attendance.work_date
  end

  test "should destroy attendance" do
    assert_difference("Attendance.count", -1) do
      delete employee_attendance_url(@employee, @attendance), params: { month: "2026-03" }
    end

    assert_redirected_to employee_url(@employee, month: "2026-03")
  end
end
