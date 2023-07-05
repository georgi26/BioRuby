require_relative "./lib/bioruby.rb"
dir = "/home/georgi/Documents/LabResults/DNA/GCF_000001405.25_biolabi"
dd = Dir.open(dir)
dd.each_child do |d|
  chrCache = BioLabi::ChrCache.new(:"1", "#{dir}/#{d}")
  chrCache.sortFile
end
