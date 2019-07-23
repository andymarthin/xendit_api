# frozen_string_literal: true

module XenditApi
  module Entities
    class Ewallet < Base
      extend ModelAttribute

      attribute :external_id,       :string
      attribute :amount,            :integer
      attribute :ewallet_type,      :string
      attribute :business_id,       :string
      attribute :transaction_date,  :string

      def initialize(attributes = {})
        set_attributes(attributes)
      end
    end
  end
end
