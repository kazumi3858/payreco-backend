# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'has a valid factory' do
    expect(build(:company)).to be_valid
  end
end
