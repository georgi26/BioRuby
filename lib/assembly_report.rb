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
        data = line.split
        if (!line.start_with?("#") && data.size > 6)
          chr = data[0].chomp.to_sym
          chrInt = chr.to_s.to_i
          if ((1..22).include?(chrInt) || chr == :X || chr == :Y || chr == :MT)
            @chromosomes_map[data[4].chomp] = chr
            @chromosomes_map[data[6].chomp] = chr
          end
        end
      end
    end
  end
end
