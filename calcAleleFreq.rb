require_relative "./lib/bioruby.rb"
if (ARGV.size == 0)
  puts "Give path to .vcf file as argument "
  return
end
file = ARGV[0]
basename = File.basename(file)
puts "Start"
t0 = Time.now
puts "Started ad #{t0}"
yourFile = BioLabi::VCFFile.new(file)
puts "Load file #{yourFile.path}"
yourFile.load
puts "Loaded"
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
totalAllels = 0
result = {}
PRINT_INCREMENT = 1000000
printLimitCount = PRINT_INCREMENT

class VObject
  attr_reader :value, :count, :total

  def initialize()
    @value = 0.0
    @count = 0
    @total = 0
  end

  def incrementCount()
    @count = @count + 2
  end

  def incrementValueWith(increment)
    incrementCount()
    @value = @value + increment
  end

  def to_s
    [value, count, percent, total].to_s
  end

  def percent
    (value / count) * 100
  end

  def updateTotal(totalAllels)
    @total = percent * (count.to_f / totalAllels)
  end
end

genome37File.each_row do |row|
  if (row.vc == "SNV" && row.freq)
    totalAllels += 2
    found = yourFile.findRow(row.chromosome, row.position)
    if (found)
      found.mergeReference(row)
      if (found.ac == 2)
        row.freq.each do |freq|
          key = freq[0]
          result[key] ||= VObject.new
          vObject = result[key]
          value = row.freqFor(key, found.alt)
          vObject.incrementValueWith(value * 2)
          vObject.updateTotal(totalAllels)
        end
      else
        row.freq.each do |freq|
          key = freq[0]
          result[key] ||= VObject.new
          vObject = result[key]
          value = row.freqFor(key, found.alt)
          value2 = row.freqFor(key, found.ref)
          vObject.incrementValueWith(value + value2)
          vObject.updateTotal(totalAllels)
        end
      end
    else
      row.freq.each do |freq|
        key = freq[0]
        result[key] ||= VObject.new
        vObject = result[key]
        values = freq[1]
        vObject.incrementValueWith(values[0].to_f * 2)
        vObject.updateTotal(totalAllels)
      end
    end
    if (totalAllels >= printLimitCount)
      puts "Update Total #{totalAllels}"
      puts "Update results #{result}"
      puts "Update results #{result.map { |k, v| "#{k}: #{v.total} %" }}"
      printLimitCount += PRINT_INCREMENT
    end
  end
end

t1 = Time.now
puts "Total #{totalAllels}"
puts "Freq #{result}"
puts "Result #{result.map { |k, v| "#{k}: #{v.total} %" }}"
puts "Start Time:#{t0} End time : #{t1} took #{t1 - t0}"
