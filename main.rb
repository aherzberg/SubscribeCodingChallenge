require_relative 'item'
require_relative 'receipt'

def parse_item(line)
  if match = line.match(/^(\d+)\s+(.+?)\s+at\s+(\d+\.\d{2})$/)
    quantity = match[1].to_i
    name = match[2].strip
    price = match[3].to_f
    imported = name.downcase.include?('imported')
    Item.new(name, price, quantity, imported)
  else
    raise ArgumentError, "Invalid input format. Expected format: '<quantity> <item> at <price>'"
  end
end

def process_shopping_basket(input_file)
  items = []
  
  lines = File.readlines(input_file)
  
  lines.each do |line|
    line = line.chomp
    next if line.empty?
    
    begin
      items << parse_item(line)
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      puts "Skipping invalid line."
    end
  end

  if items.empty?
    puts "No valid items found in the input file."
    return
  end

  receipt = Receipt.new(items)
  puts "\nReceipt:"
  receipt.print_receipt
rescue Errno::ENOENT
  puts "Error: Input file '#{input_file}' not found."
  exit 1
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "Usage: ruby main.rb <input_file.txt>"
    exit 1
  end

  input_file = ARGV[0]
  process_shopping_basket(input_file)
end
