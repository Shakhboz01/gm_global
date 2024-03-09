# total paid might be null, it means provider paid fully at once
# ignored service_price
class ProductEntry < ApplicationRecord
  attr_accessor :excel_data
  attr_accessor :product_category_id

  belongs_to :combination_of_local_product, optional: true
  belongs_to :delivery_from_counterparty
  has_one :provider, through: :delivery_from_counterparty
  has_one :user, through: :delivery_from_counterparty
  belongs_to :product
  belongs_to :storage
  validates :amount, comparison: { greater_than: 0 }
  validates :sell_price, :buy_price, comparison: { greater_than_or_equal_to: 0 }
  validates_presence_of :buy_price, unless: -> { local_entry }

  before_create :set_currency_and_update_product_price
  before_create :proccess_increment
  before_create :set_price_in_percentage
  before_destroy :proccess_decrement
  before_create :update_delivery_currency
  before_update :set_price_in_percentage
  after_create :update_delivery_category

  scope :paid_in_uzs, -> { where('paid_in_usd = ?', false) }
  scope :paid_in_usd, -> { where('paid_in_usd = ?', true) }

  private

  def set_currency_and_update_product_price
    self.paid_in_usd = product.price_in_usd
    product.update(sell_price: sell_price, buy_price: buy_price)
  end

  def set_price_in_percentage
    return if new_record? && !price_in_percentage.nil?

    price_in_usd = product.price_in_usd
    product_sell_price = product.sell_price
    if price_in_usd && !paid_in_usd
      product_buy_price = buy_price / rate
    elsif !price_in_usd && paid_in_usd
      product_buy_price = buy_price * rate
    else
      product_buy_price = buy_price
    end

    self.price_in_percentage = (product_sell_price * 100 / buy_price) - 100
  end

  def proccess_decrement
    delivery_from_counterparty.decrement!(:total_price, (buy_price * amount))
    product.decrement!(:initial_remaining, amount)
  end

  def proccess_increment
    delivery_from_counterparty.increment!(:total_price, (amount * buy_price))
    product.increment!(:initial_remaining, amount)
  end

  def update_delivery_currency
    return if delivery_from_counterparty.nil? || delivery_from_counterparty.price_in_usd == paid_in_usd

    delivery_from_counterparty.update(price_in_usd: paid_in_usd)
  end

  def update_delivery_category
    return if delivery_from_counterparty&.product_category_id == product.product_category_id

    delivery_from_counterparty.update(product_category_id: product.product_category_id)
  end

  def change_buy_price
    return if paid_in_usd == paid_in_usd_was

    rate = CurrencyRate.last.rate
    if paid_in_usd_was == false && paid_in_usd == true
      self.buy_price = buy_price / rate
    elsif paid_in_usd_was == true && paid_in_usd == false
      self.buy_price = buy_price * rate
    end
  end
end
