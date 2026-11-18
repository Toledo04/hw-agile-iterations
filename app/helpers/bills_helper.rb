# frozen_string_literal: true

module BillsHelper
  BILL_TYPE_NAMES = {
    'HR'      => 'House Bill',
    'S'       => 'Senate Bill',
    'HJRES'   => 'House Joint Resolution',
    'SJRES'   => 'Senate Joint Resolution',
    'HCONRES' => 'House Concurrent Resolution',
    'SCONRES' => 'Senate Concurrent Resolution',
    'HRES'    => 'House Simple Resolution',
    'SRES'    => 'Senate Simple Resolution'
  }.freeze

  def bill_number_label(bill)
    "#{bill['type'].to_s.upcase} #{bill['number']}"
  end

  def bill_type_name(bill)
    BILL_TYPE_NAMES.fetch(bill['type'].to_s.upcase, bill['type'])
  end

  def bill_last_action(bill)
    action = bill['latestAction']
    return '' if action.blank?

    text = action['text'].to_s.chomp('.')
    return text if action['actionDate'].blank?

    "#{text} on #{Date.iso8601(action['actionDate']).strftime('%b %-d, %Y')}"
  end
end
