class Attendance < ApplicationRecord
  belongs_to :employee

  before_validation :set_work_date_from_check_in

  validates :work_date, :check_in_at, :check_out_at, presence: true
  validates :work_date, uniqueness: { scope: :employee_id, message: "already has a check-in for this day" }
  validate :check_out_after_check_in
  validate :work_date_matches_check_in_date

  def worked_hours
    return 0 if check_in_at.blank? || check_out_at.blank?

    ((check_out_at - check_in_at) / 1.hour).round(2)
  end

  def ot_hours
    [ worked_hours - 8, 0 ].max.round(2)
  end

  private

  def set_work_date_from_check_in
    self.work_date ||= check_in_at&.to_date
  end

  def check_out_after_check_in
    return if check_in_at.blank? || check_out_at.blank?
    return if check_out_at > check_in_at

    errors.add(:check_out_at, "must be after check in time")
  end

  def work_date_matches_check_in_date
    return if work_date.blank? || check_in_at.blank?
    return if work_date == check_in_at.to_date

    errors.add(:work_date, "must match check in date")
  end
end
