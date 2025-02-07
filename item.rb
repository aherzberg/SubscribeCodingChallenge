class Item
  attr_accessor :name, :price, :quantity, :imported

  EXEMPT_CATEGORIES = ['book', 'food', 'medical']
  
  FOOD_ITEMS = ['chocolate']
  MEDICAL_ITEMS = ['pills']
  BOOK_ITEMS = ['book']

  def initialize(name, price, quantity, imported = false)
    @name = name
    @price = price
    @quantity = quantity
    @imported = imported
  end

  def category
    name_lower = name.downcase
    return 'food' if FOOD_ITEMS.any? { |item| name_lower.include?(item) }
    return 'medical' if MEDICAL_ITEMS.any? { |item| name_lower.include?(item) }
    return 'book' if BOOK_ITEMS.any? { |item| name_lower.include?(item) }
    'other'
  end

  def exempt?
    EXEMPT_CATEGORIES.include?(category)
  end

  def round_to_nearest_005(amount)
    (amount * 20).ceil / 20.0
  end

  def sales_tax
    return 0 if exempt?
    round_to_nearest_005(price * 0.10)
  end

  def import_duty
    return 0 unless imported
    round_to_nearest_005(price * 0.05)
  end

  def total_price
    price + sales_tax + import_duty
  end
end
