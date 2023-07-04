require_relative "./lib/bioruby.rb"
puts "Start"
t0 = Time.now
puts "Started ad #{t0}"
yourFile = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/TSAB6967.filtered.snp.vcf")
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
puts "Load file #{genome37File.path}"
genome37File.load
puts "Loaded"

out = File.open("results_r_#{Time.now.strftime("%Y-%m-%d_%H_%M")}.txt", "w")
yourFile.each_row do |row|
  found = genome37File.findRow(row.chromosome, row.position)
  if (found)
    out.puts "#################################"
    out.puts row
    out.puts "---------------------------------"
    out.puts found
    out.puts "##################################"
  end
end
t1 = Time.now
puts "Ended at #{t1} took #{t1 - t0} "
out.puts "Ended at #{t1} took #{t1 - t0} "
