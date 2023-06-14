module BioLabi
  class VCFFile
    CHROMOSOMES_MAP = { "NC_000001.10" => "1",
                        "NC_000002.11" => "2",
                        "NC_000003.11" => "3",
                        "NC_000004.11" => "4",
                        "NC_000005.9" => "5",
                        "NC_000006.11" => "6",
                        "NC_000007.13" => "7",
                        "NC_000008.10" => "8",
                        "NC_000009.11" => "9",
                        "NC_000010.10" => "10",
                        "NC_000011.9" => "11",
                        "NC_000012.11" => "12",
                        "NC_000013.10" => "13",
                        "NC_000014.8" => "14",
                        "NC_000015.9" => "15",
                        "NC_000016.9" => "16",
                        "NC_000017.10" => "17",
                        "NC_000018.9" => "18",
                        "NC_000019.9" => "19",
                        "NC_000020.10" => "20",
                        "NC_000021.8" => "21",
                        "NC_000022.10" => "22",
                        "NC_000023.10" => "X",
                        "NC_000024.9" => "Y" }

    VCF_HEADER = ["#CHROM", "POS", "ID", "REF", "ALT"]

    attr_reader :cache

    def initialize(file)
      @file = file
      @cache = {}
      CHROMOSOMES_MAP.values.each do |c|
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
          if (h != lArray[i])
            return false
          end
        end
        return true
      end
      return false
    end

    def isARow(line)
      return line.split.size > VCF_HEADER.size
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
    attr_reader :chromosome, :id, :position, :ref, :alt, :raw

    def initialize(rawData)
      @raw = rawData
      self.parse
    end

    def to_s
      raw
    end

    private

    def parse()
      tokens = @raw.split
      @chromosome = VCFFile::CHROMOSOMES_MAP[tokens[0]]
      unless @chromosome
        @chromosome = tokens[0]
      end
      @position = tokens[1].to_i
      @id = tokens[2]
      @ref = tokens[3]
      @alt = tokens[4]
    end
  end
end
