require_relative "./lib/vcf_file.rb"

yourFile = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/TSAB6967.filtered.snp.vcf")
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
yourFile.load
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
