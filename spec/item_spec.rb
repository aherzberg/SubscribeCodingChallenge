RSpec.describe Item do
  describe '#category' do
    it 'identifies food items' do
      item = Item.new('chocolate bar', 0.85, 1)
      expect(item.category).to eq('food')
    end

    it 'identifies medical items' do
      item = Item.new('headache pills', 9.75, 1)
      expect(item.category).to eq('medical')
    end

    it 'identifies book items' do
      item = Item.new('book', 12.49, 1)
      expect(item.category).to eq('book')
    end

    it 'identifies other items' do
      item = Item.new('music CD', 14.99, 1)
      expect(item.category).to eq('other')
    end
  end

  describe '#exempt?' do
    it 'returns true for books' do
      item = Item.new('book', 12.49, 1)
      expect(item).to be_exempt
    end

    it 'returns true for food' do
      item = Item.new('chocolate bar', 0.85, 1)
      expect(item).to be_exempt
    end

    it 'returns true for medical items' do
      item = Item.new('headache pills', 9.75, 1)
      expect(item).to be_exempt
    end

    it 'returns false for other items' do
      item = Item.new('music CD', 14.99, 1)
      expect(item).not_to be_exempt
    end
  end

  describe '#round_to_nearest_005' do
    it 'rounds up to the nearest 0.05' do
      item = Item.new('music CD', 14.99, 1)
      expect(item.round_to_nearest_005(1.23)).to eq(1.25)
      expect(item.round_to_nearest_005(1.22)).to eq(1.25)
      expect(item.round_to_nearest_005(1.21)).to eq(1.25)
    end
  end

  describe '#sales_tax' do
    context 'for exempt items' do
      it 'returns 0 for books' do
        item = Item.new('book', 12.49, 1)
        expect(item.sales_tax).to eq(0)
      end

      it 'returns 0 for food' do
        item = Item.new('chocolate bar', 0.85, 1)
        expect(item.sales_tax).to eq(0)
      end

      it 'returns 0 for medical items' do
        item = Item.new('headache pills', 9.75, 1)
        expect(item.sales_tax).to eq(0)
      end
    end

    context 'for non-exempt items' do
      it 'calculates 10% sales tax rounded to nearest 0.05' do
        item = Item.new('music CD', 14.99, 1)
        expect(item.sales_tax).to eq(1.50) # 14.99 * 0.10 = 1.499 -> 1.50
      end
    end
  end

  describe '#import_duty' do
    context 'for imported items' do
      it 'calculates 5% import duty rounded to nearest 0.05' do
        item = Item.new('imported box of chocolates', 10.00, 1, true)
        expect(item.import_duty).to eq(0.50) # 10.00 * 0.05 = 0.50
      end

      it 'applies to both exempt and non-exempt items' do
        exempt_item = Item.new('imported box of chocolates', 10.00, 1, true)
        non_exempt_item = Item.new('imported bottle of perfume', 47.50, 1, true)

        expect(exempt_item.import_duty).to eq(0.50)
        expect(non_exempt_item.import_duty).to eq(2.40) # 47.50 * 0.05 = 2.375 -> 2.40
      end
    end

    context 'for non-imported items' do
      it 'returns 0' do
        item = Item.new('book', 12.49, 1)
        expect(item.import_duty).to eq(0)
      end
    end
  end

  describe '#total_price' do
    it 'returns base price for exempt, non-imported items' do
      item = Item.new('book', 12.49, 1)
      expect(item.total_price).to eq(12.49)
    end

    it 'includes sales tax for non-exempt items' do
      item = Item.new('music CD', 14.99, 1)
      expect(item.total_price).to be_within(0.001).of(16.49) # 14.99 + 1.50 sales tax
    end

    it 'includes import duty for imported items' do
      item = Item.new('imported box of chocolates', 10.00, 1, true)
      expect(item.total_price).to eq(10.50) # 10.00 + 0.50 import duty
    end

    it 'includes both taxes for non-exempt imported items' do
      item = Item.new('imported bottle of perfume', 47.50, 1, true)
      expect(item.total_price).to eq(54.65) # 47.50 + 4.75 sales tax + 2.40 import duty
    end
  end
end
