module ProductEntries
  class ImportExcel < ActiveInteraction::Base
    file :excel_data
    integer :product_category_id
    decimal :price_in_percentage, default: 0
    integer :storage_id
    integer :delivery_from_counterparty_id

    def execute
      excel = Roo::Excelx.new(excel_data.path)
      header = excel.row(1)
      (2..excel.last_row).each do |i|
        row_data = Hash[[header, excel.row(i)].transpose]
        name = row_data.values[0]
        amount = row_data.values[1]
        buy_price = row_data.values[2].gsub(/[[:space:]]/, '').to_f
        sell_price = row_data.values[3]&.gsub(/[[:space:]]/, '')&.to_f
        next unless name.present? && amount.present? && buy_price.present?

        words = name.split
        code = words[0]
        name = words[1..].join(' ')
        pr = Product.find_by_code(code)
        if pr.nil?
          pr = Product.create(name: name, code: code, unit: 0, product_category_id: product_category_id)
        end

        sell_price ||= (buy_price + (buy_price * price_in_percentage / 100))
        self.price_in_percentage = (sell_price  * 100 / buy_price) - 100
        ProductEntry.create(
          buy_price: buy_price,
          sell_price: sell_price,
          product: pr,
          amount: amount,
          storage_id: storage_id,
          delivery_from_counterparty_id: delivery_from_counterparty_id,
          price_in_percentage: price_in_percentage
        )
      end
    end
  end
end
