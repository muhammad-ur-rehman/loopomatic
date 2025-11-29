class ReturnRequest < ApplicationRecord
  enum :decision, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    manual_review: 'manual_review'
  }, suffix: true

  enum :resolution, {
    none: 'none',
    refund: 'refund',
    exchange: 'exchange',
    store_credit: 'store_credit'
  }, prefix: true

  validates :order_id, presence: true
  validates :customer_id, presence: true
  validates :order_value_cents, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :reason, presence: true
  validates :description, presence: true
end
