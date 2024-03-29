# frozen_string_literal: true

class Company < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id, inverse_of: :companies
  has_many :works # rubocop:disable Rails/HasManyOrHasOneDependent
  validates :name, presence: true, length: { in: 1..30 }
  validates :wage_amount, numericality: { allow_nil: true, in: 1..99999 }
  validates :hourly_wage_system, inclusion: { in: [true, false] }
  validates :currency_type, presence: true
end
