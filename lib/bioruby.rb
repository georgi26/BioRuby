require "json"
require "logger"

module BioLabi
  LOGGER = Logger.new($stdout)
end

require_relative "./assembly_report.rb"
require_relative "./chr_cache.rb"
require_relative "./vcf_file.rb"
