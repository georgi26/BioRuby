module BioLabi
  class AssemblyReport
    def initialize(filePath = "#{File.dirname(__FILE__)}/GRCh37.p13_assembly_report.txt")
      @file = filePath
      @chromosomes_map = {}
      parseFile
    end

    def [](chromosome)
      result = nil
      if (isChromosome(chromosome))
        result = chromosome.to_sym
      else
        result = @chromosomes_map[chromosome]
      end
      result
    end

    def isChromosome(data)
      chr = data.to_sym
      chrInt = data.to_s.to_i
      ((1..22).include?(chrInt) || chr == :X || chr == :Y || chr == :MT)
    end

    def parseFile()
      File.foreach(@file) do |line|
        data = line.split
        if (!line.start_with?("#") && data.size > 6)
          chr = data[0].chomp.to_sym
          if (isChromosome(chr))
            @chromosomes_map[data[4].chomp] = chr
            @chromosomes_map[data[6].chomp] = chr
          end
        end
      end
    end
  end
end
