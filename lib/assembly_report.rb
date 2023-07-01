module BioLabi
  class AssemblyReport
    attr_reader :chromosomes_map

    def initialize(filePath = "#{File.dirname(__FILE__)}/GRCh37.p13_assembly_report.txt")
      @file = filePath
      @chromosomes_map = {}
      parseFile
    end

    def parseFile()
      File.foreach(@file) do |line|
        if (!line.start_with? "#")
          data = line.split
          if (data.size > 6)
            @chromosomes_map[data[4].chomp] = data[2].chomp.to_sym
            @chromosomes_map[data[6].chomp] = data[2].chomp.to_sym
          end
        end
      end
    end
  end
end
