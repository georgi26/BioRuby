require_relative "./lib/bioruby.rb"

chrCache = BioLabi::ChrCache.new(:"1", "./1.idx")
found = ""
t0 = Time.now
found = chrCache.binSearch 3319681
t1 = Time.now
puts "Time: #{t1 - t0}"
puts "Size: #{found}"
