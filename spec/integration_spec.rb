require 'tempfile'
require_relative '../main'

RSpec.describe 'File Input Processing' do
  let(:output) { StringIO.new }
  
  before do
    # Redirect stdout to capture output
    $stdout = output
  end
  
  after do
    # Restore stdout
    $stdout = STDOUT
  end

  def verify_receipt_output(actual_output, expected_items, expected_sales_tax, expected_total)
    lines = actual_output.split("\n")
    
    # Verify each item line
    expected_items.each do |item|
      expect(lines).to include(item)
    end

    # Verify sales tax and total
    expect(lines).to include("Sales Taxes: #{expected_sales_tax}")
    expect(lines).to include("Total: #{expected_total}")
  end

  context 'with valid input file' do
    let(:input_file) do
      Tempfile.new(['shopping_list', '.txt']).tap do |f|
        f.write("1 book at 12.49\n")
        f.write("1 music CD at 14.99\n")
        f.write("1 chocolate bar at 0.85\n")
        f.close
      end
    end

    after do
      input_file.unlink
    end

    it 'processes items and generates correct receipt' do
      process_shopping_basket(input_file.path)

      expect(output.string).to include('1 book: 12.49')
      expect(output.string).to include('1 music CD: 16.49')
      expect(output.string).to include('1 chocolate bar: 0.85')
      expect(output.string).to include('Sales Taxes: 1.50')
      expect(output.string).to include('Total: 29.83')
    end
  end

  context 'with input 1' do
    let(:input_file) do
      Tempfile.new(['input1', '.txt']).tap do |f|
        f.write("2 book at 12.49\n")
        f.write("1 music CD at 14.99\n")
        f.write("1 chocolate bar at 0.85\n")
        f.close
      end
    end

    after do
      input_file.unlink
    end

    it 'generates correct receipt for input 1' do
      process_shopping_basket(input_file.path)
      
      expected_items = [
        "2 book: 24.98",
        "1 music CD: 16.49",
        "1 chocolate bar: 0.85"
      ]
      
      verify_receipt_output(
        output.string,
        expected_items,
        "1.50",
        "42.32"
      )
    end
  end

  context 'with input 2' do
    let(:input_file) do
      Tempfile.new(['input2', '.txt']).tap do |f|
        f.write("1 imported box of chocolates at 10.00\n")
        f.write("1 imported bottle of perfume at 47.50\n")
        f.close
      end
    end

    after do
      input_file.unlink
    end

    it 'generates correct receipt for input 2' do
      process_shopping_basket(input_file.path)
      
      expected_items = [
        "1 imported box of chocolates: 10.50",
        "1 imported bottle of perfume: 54.65"
      ]
      
      verify_receipt_output(
        output.string,
        expected_items,
        "7.65",
        "65.15"
      )
    end
  end

  context 'with input 3' do
    let(:input_file) do
      Tempfile.new(['input3', '.txt']).tap do |f|
        f.write("1 imported bottle of perfume at 27.99\n")
        f.write("1 bottle of perfume at 18.99\n")
        f.write("1 packet of headache pills at 9.75\n")
        f.write("3 imported boxes of chocolates at 11.25\n")
        f.close
      end
    end

    after do
      input_file.unlink
    end

    it 'generates correct receipt for input 3' do
      process_shopping_basket(input_file.path)
      
      expected_items = [
        "1 imported bottle of perfume: 32.19",
        "1 bottle of perfume: 20.89",
        "1 packet of headache pills: 9.75",
        "3 imported boxes of chocolates: 35.55"
      ]
      
      verify_receipt_output(
        output.string,
        expected_items,
        "7.90",
        "98.38"
      )
    end
  end

  context 'with empty input file' do
    let(:empty_file) do
      Tempfile.new(['empty_list', '.txt']).tap(&:close)
    end

    after do
      empty_file.unlink
    end

    it 'handles empty file gracefully' do
      process_shopping_basket(empty_file.path)
      expect(output.string).to include('No valid items found in the input file')
    end
  end

  context 'with invalid input file' do
    let(:invalid_file) do
      Tempfile.new(['invalid_list', '.txt']).tap do |f|
        f.write("invalid format\n")
        f.write("1 book at price\n")
        f.close
      end
    end

    after do
      invalid_file.unlink
    end

    it 'handles invalid format gracefully' do
      process_shopping_basket(invalid_file.path)
      expect(output.string).to include('Error: Invalid input format')
      expect(output.string).to include('No valid items found in the input file')
    end
  end

  context 'with non-existent file' do
    it 'handles missing file gracefully' do
      expect {
        process_shopping_basket('non_existent_file.txt')
      }.to raise_error(SystemExit)
      expect(output.string).to include("Error: Input file 'non_existent_file.txt' not found")
    end
  end

  context 'with mixed valid and invalid lines' do
    let(:mixed_file) do
      Tempfile.new(['mixed_list', '.txt']).tap do |f|
        f.write("1 book at 12.49\n")
        f.write("invalid line\n")
        f.write("1 imported bottle of perfume at 47.50\n")
        f.close
      end
    end

    after do
      mixed_file.unlink
    end

    it 'processes valid items and skips invalid ones' do
      process_shopping_basket(mixed_file.path)
      
      expected_items = [
        "1 book: 12.49",
        "1 imported bottle of perfume: 54.65"
      ]
      
      verify_receipt_output(
        output.string,
        expected_items,
        "7.15",
        "67.14"
      )
      
      expect(output.string).to include('Error: Invalid input format')
    end
  end
end
