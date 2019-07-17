# frozen_string_literal: true

require 'spec_helper'

module XenditApi::Entities
  describe Ewallet do
    it { should respond_to(:external_id) }
    it { should respond_to(:amount) }
    it { should respond_to(:business_id) }
    it { should respond_to(:ewallet_type) }
    it { should respond_to(:transaction_date) }
  end
end
