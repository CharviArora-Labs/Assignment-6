class Appointment < ApplicationRecord
  enum :status, {
    scheduled: "scheduled",
    cancelled: "cancelled"
  }

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true

  validate :end_after_start
  validate :no_time_overlap, if: :scheduled?

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_time_overlap
    overlapping = Appointment
      .where.not(id: id)
      .where(status: "scheduled")
      .where("start_time < ? AND end_time > ?", end_time, start_time)

    if overlapping.exists?
      errors.add(:base, "Appointment time overlaps with another scheduled appointment")
    end
  end
end
