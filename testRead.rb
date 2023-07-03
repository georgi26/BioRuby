require_relative "./lib/bioruby.rb"

chrCache = BioLabi::ChrCache.new(:"1",
                                 "/home/georgi/Documents/LabResults/DNA/GCF_000001405.25_biolabi/1.idx")
t0 = Time.now
chrCache.load()
t1 = Time.now
puts "Time: #{t1 - t0}"
puts "Size: #{chrCache.size}"
