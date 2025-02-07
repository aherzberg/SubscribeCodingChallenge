RSpec.describe Receipt do
  let(:book) { double('Item', quantity: 2, name: 'book', total_price: 12.49, sales_tax: 0, import_duty: 0) }
  let(:cd) { double('Item', quantity: 1, name: 'music CD', total_price: 16.49, sales_tax: 1.50, import_duty: 0) }
  let(:chocolate) { double('Item', quantity: 1, name: 'chocolate bar', total_price: 0.85, sales_tax: 0, import_duty: 0) }
  
  let(:receipt) { Receipt.new([book, cd, chocolate]) }

  describe '#total_sales_tax' do
    it 'calculates the total sales tax for all items' do
      expect(receipt.total_sales_tax).to eq(1.50)
    end
  end

  describe '#total_cost' do
    it 'calculates the total cost including taxes' do
      # (12.49 * 2) + 16.49 + 0.85 = 42.32
      total = (book.total_price * book.quantity) + cd.total_price + chocolate.total_price
      expect(receipt.total_cost).to eq(total)
    end
  end

  describe '#format_price' do
    it 'formats the price with 2 decimal places' do
      expect(receipt.format_price(42.324)).to eq('42.32')
      expect(receipt.format_price(0.8)).to eq('0.80')
    end
  end

  describe '#print_receipt' do
    it 'prints the receipt in the correct format' do
      expected_output = [
        "2 book: #{receipt.format_price(book.total_price * book.quantity)}",
        "1 music CD: #{receipt.format_price(cd.total_price)}",
        "1 chocolate bar: #{receipt.format_price(chocolate.total_price)}",
        "Sales Taxes: #{receipt.format_price(receipt.total_sales_tax)}",
        "Total: #{receipt.format_price(receipt.total_cost)}"
      ].join("\n") + "\n"

      expect { receipt.print_receipt }.to output(expected_output).to_stdout
    end
  end
end
