require_relative "./lib/bioruby.rb"
if (ARGV.size == 0)
  puts "Give path to .vcf file as argument "
  return
end
file = ARGV[0]
basename = File.basename(file)
puts "Start"
t0 = Time.now
puts "Started at #{t0}"
yourFile = BioLabi::VCFFile.new(file)
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
puts "Load file #{genome37File.path}"
genome37File.load
puts "Loaded"

out = File.open("#{basename}_#{Time.now.strftime("%Y-%m-%d_%H_%M")}.csv", "w")
out.puts BioLabi::VCFRow.csv_header
sig = File.open("#{basename}_#{Time.now.strftime("%Y-%m-%d_%H_%M")}_clnsig.csv", "w")
sig.puts BioLabi::VCFRow.csv_header
sig4 = File.open("#{basename}_#{Time.now.strftime("%Y-%m-%d_%H_%M")}_clnsig4.csv", "w")
sig4.puts BioLabi::VCFRow.csv_header
yourFile.each_row do |row|
  found = genome37File.findRow(row.chromosome, row.position)
  if (found)
    row.mergeReference found
    out.puts row.to_csv
    if (found.maxCLNSIG > 0)
      sig.puts row.to_csv
    end
    if (found.maxCLNSIG > 3)
      sig4.puts row.to_csv
    end
  end
end
t1 = Time.now
puts "Ended at #{t1} took #{t1 - t0} "
