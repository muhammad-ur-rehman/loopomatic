class Rule < ApplicationRecord
  validates :name, presence: true
  validates :priority, numericality: { only_integer: true }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_priority, -> { order(priority: :asc) }

  def self.active_by_priority
    active.by_priority
  end
end
