# frozen_string_literal: true

# == Schema Information
#
# Table name: bills
#
#  id               :integer          not null, primary key
#  bill_type        :string
#  congress         :integer
#  number           :integer
#  original_chamber :string
#  summary          :text
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_bills_on_congress_and_bill_type_and_number  (congress,bill_type,number) UNIQUE
#
require 'rails_helper'

describe Bill do
  let(:attributes) do
    {
      title: 'A test bill',
      congress: 119,
      number: 123,
      original_chamber: 'House',
      bill_type: 'hr',
      summary: 'A summary of the bill.'
    }
  end

  it 'saves the bill details' do
    bill = described_class.create!(attributes)

    expect(bill.reload).to have_attributes(attributes)
  end

  it 'does not allow the same bill to be saved twice' do
    described_class.create!(attributes)
    duplicate = described_class.new(attributes)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:number]).to be_present
  end

  %i[title congress number original_chamber bill_type summary].each do |attribute|
    it "requires #{attribute}" do
      bill = described_class.new(attributes.except(attribute))

      expect(bill).not_to be_valid
      expect(bill.errors[attribute]).to be_present
    end
  end
end
