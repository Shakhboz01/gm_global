module DataPopulation
  class PopulateBuyers < ActiveInteraction::Base
    def execute
      buyers_data = JSON.parse(File.read('app/assets/javascripts/buyers.json'))
      buyers_data.each do |buyer_data|
        create_buyers(buyer_data)
      end
    end

    private

    def create_buyers(data)
      buyer =
        Buyer.create(
          name: data['buyer_name'],
          phone_number: data['phone_number'],
          active: true,
          debt_in_uzs: data['debt_in_uzs'],
          debt_in_usd: data['debt_in_usd']
        )
    end
  end
end
