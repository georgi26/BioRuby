require_relative "./lib/bioruby.rb"
puts "Start"
t0 = Time.now
puts "Started ad #{t0}"
yourFile = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/TSAB6967.filtered.vcf")
genome37File = BioLabi::VCFFile.new("/home/georgi/Documents/LabResults/DNA/GCF_000001405.25")
puts "Load file #{genome37File.path}"
genome37File.load
puts "Loaded"

out = File.open("results_r_#{Time.now.strftime("%Y-%m-%d_%H_%M")}_.txt", "w")
sig = File.open("results_r_#{Time.now.strftime("%Y-%m-%d_%H_%M")}_clnsig.txt", "w")
sig4 = File.open("results_r_#{Time.now.strftime("%Y-%m-%d_%H_%M")}_clnsig4.txt", "w")
yourFile.each_row do |row|
  found = genome37File.findRow(row.chromosome, row.position)
  if (found)
    row.mergeReference found
    out.puts row.to_json
    if (found.maxCLNSIG > 0)
      sig.puts row.to_clin_json
    end
    if (found.maxCLNSIG > 3)
      sig4.puts row.to_clin_json
    end
  end
end
t1 = Time.now
puts "Ended at #{t1} took #{t1 - t0} "
