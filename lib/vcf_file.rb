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
            @chromosomes_map[data[4].chomp] = data[2].chomp
            @chromosomes_map[data[6].chomp] = data[2].chomp
          end
        end
      end
    end
  end

  class VCFFile
    ASSEMBLY_REPORT = AssemblyReport.new

    VCF_HEADER = [:"#CHROM", :"POS", :"ID", :"REF", :"ALT", :"QUAL", :"FILTER", :"INFO"]

    attr_reader :cache, :file

    def initialize(file)
      @file = file
      @cache = {}
      ASSEMBLY_REPORT.chromosomes_map.values.each do |c|
        @cache[c.to_sym] = {}
      end
    end

    def isLineHeader(line)
      if (line.start_with? "##")
        return false
      end
      lArray = line.split
      if (lArray.size >= VCF_HEADER.size)
        VCF_HEADER.each_with_index do |h, i|
          if (h.to_sym != lArray[i].to_sym)
            return false
          end
        end
        return true
      end
      return false
    end

    def isARow(line)
      return line.split.size >= VCF_HEADER.size
    end

    def each_row
      started = false
      File.foreach(@file) do |line|
        if started
          if (isARow(line))
            row = VCFRow.new line
            yield row
          end
        else
          started = isLineHeader(line)
        end
      end
    end

    def load()
      self.each_row do |row|
        c = @cache[row.chromosome.to_sym]
        if (c.is_a? Hash)
          c[row.position] = row
        end
      end
    end

    def findRow(chrom, position)
      @cache[chrom.to_sym][position]
    end
  end

  class VCFRow
    attr_reader :chromosome, :id, :position, :ref, :alt, :info, :raw

    def initialize(rawData)
      @raw = rawData
      self.parse
    end

    def to_s
      raw
    end

    def clnsig
      unless @clnsig
        @clnsig = @info[:CLNSIG]
        if (@clnsig && @clnsig.is_a?(Array))
          @clnsig = @clnsig[0].to_i
        elsif (@clnsig)
          @clnsig = @clnsig.to_i
        end
      end
      @clnsig
    end

    private

    def parse()
      tokens = @raw.split
      @chromosome = VCFFile::ASSEMBLY_REPORT.chromosomes_map[tokens[0]]
      unless @chromosome
        @chromosome = tokens[0]
      end
      @position = tokens[1].to_i
      @id = tokens[2]
      @ref = tokens[3]
      @alt = tokens[4]
      @info = parseInfo(tokens[7])
    end

    def parseInfo(input)
      result = {}
      rows = input.split(";")
      rows.each do |r|
        rr = r.split("=")
        if (rr.size >= 2)
          key = rr[0]
          values = rr[1].split ","
          result[key.to_sym] = values
        end
      end
      result
    end
  end
end
