class DeliveryFromCounterparty < ApplicationRecord
  include HandleTransactionHistory
  belongs_to :provider
  belongs_to :product_category, optional: true
  belongs_to :user
  has_many :expenditures
  has_many :product_entries, dependent: :destroy
  has_many :transaction_histories, dependent: :destroy
  enum status: %i[processing closed]
  enum payment_type: %i[наличные карта click предоплата перечисление дригие]
  scope :unpaid, -> { where("total_price > total_paid") }
  scope :price_in_uzs, -> { where('price_in_usd = ?', false) }
  scope :price_in_usd, -> { where('price_in_usd = ?', true) }
  scope :filter_by_total_paid_less_than_price, ->(value) {
          if value == "1"
            where("total_paid < total_price")
          else
            all
          end
        }
  before_update :update_product_entries_prices
  after_save :process_status_change, if: :saved_change_to_status?

  def calculate_sell_price
    sell_price = 0
    self.product_entries.each do |product_entry|
      sell_price += product_entry.amount * product_entry.sell_price
    end

    sell_price
  end

  private

  def process_status_change
    if closed? && status_before_last_save != 'closed'
      if enable_to_send_sms
        price_sign = price_in_usd ? '$' : 'сум'
        message =  "#{user.name.upcase} оформил приход товара от контрагента" \
          "<b>Контрагент</b>: #{provider.name}\n" \
          "<b>Тип оплаты</b>: #{payment_type}\n" \
          "<b>Итого цена:</b> #{total_price} #{price_sign}\n"
        message << "&#9888<b>Оплачено:</b> #{total_paid} #{price_sign}\n" if total_price > total_paid
        message << "<b>Комментарие:</b> #{comment}\n" if comment.present?
        message << "Нажмите <a href=\"https://#{ENV.fetch('HOST_URL')}/delivery_from_counterparties/#{self.id}\">здесь</a> для просмотра"
        SendMessage.run(message: message)
      else
        self.enable_to_send_sms = false
      end
    end
  end

  def update_product_entries_prices
    return if product_entries.empty?

    product_entries.each do |entry|
      entry.update(paid_in_usd: price_in_usd)
    end

    self.total_price = product_entries.sum('buy_price * amount')
  end
end
