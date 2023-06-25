require_relative "./lib/vcf_file.rb"
puts "Start"
t0 = Time.now
puts "Started ad #{t0}"
yourFile = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/TSAB6967.filtered.snp.vcf")
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
puts "Load file #{yourFile.file}"
yourFile.load
puts "Loaded"
genome37File.each_row do |row|
  found = yourFile.findRow(row.chromosome, row.position)
  if (found)
    puts "#################################"
    puts found
    puts "---------------------------------"
    puts row
    puts "##################################"
  end
end
t1 = Time.now
puts "Ended at #{t1} took #{t1 - t0} "
