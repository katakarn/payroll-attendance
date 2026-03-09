class Employee < ApplicationRecord
  has_many :attendances, dependent: :destroy

  validates :name, :position, presence: true
  validates :base_salary, numericality: { greater_than: 0 }

  def monthly_attendances(month = Date.current)
    current_month = month.to_date.beginning_of_month
    attendances.where(work_date: current_month..current_month.end_of_month)
  end

  def working_days(month = Date.current)
    monthly_attendances(month).count
  end

  def ot_hours(month = Date.current)
    monthly_attendances(month).sum(&:ot_hours).round(2)
  end

  def hourly_rate
    base_salary / 30 / 8
  end

  def ot_pay(month = Date.current)
    (ot_hours(month) * hourly_rate).round(2)
  end

  def gross_pay(month = Date.current)
    (base_salary + ot_pay(month)).round(2)
  end

  def tax(month = Date.current)
    income = gross_pay(month)

    return 0.to_d if income <= 30_000
    return ((income - 30_000) * 0.05).round(2) if income <= 50_000

    (20_000 * 0.05 + (income - 50_000) * 0.10).round(2)
  end

  def net_pay(month = Date.current)
    (gross_pay(month) - tax(month)).round(2)
  end
end
