class Receipt
  def initialize(items)
    @items = items
  end

  def total_sales_tax
    @items.sum { |item| (item.sales_tax + item.import_duty) * item.quantity }.round(2)
  end

  def total_cost
    @items.sum { |item| item.total_price * item.quantity }.round(2)
  end

  def format_price(price)
    format("%.2f", price)
  end

  def print_receipt
    @items.each do |item|
      puts "#{item.quantity} #{item.name}: #{format_price(item.total_price * item.quantity)}"
    end
    puts "Sales Taxes: #{format_price(total_sales_tax)}"
    puts "Total: #{format_price(total_cost)}"
  end
end
