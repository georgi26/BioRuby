require_relative "./lib/bioruby.rb"
puts "Start"
t0 = Time.now
puts "Started ad #{t0}"
yourFile = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/TSAB6967.filtered.snp.vcf")
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
puts "Load file #{genome37File.path}"
genome37File.load
puts "Loaded"

yourFile.each_row do |row|
  found = genome37File.findRow(row.chromosome, row.position)
  if (found)
    puts "#################################"
    puts row
    puts "---------------------------------"
    puts found
    puts "##################################"
  end
end
t1 = Time.now
puts "Ended at #{t1} took #{t1 - t0} "
