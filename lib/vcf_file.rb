module BioLabi
  class VCFFile
    ASSEMBLY_REPORT = AssemblyReport.new

    VCF_HEADER = [:"#CHROM", :"POS", :"ID", :"REF", :"ALT", :"QUAL", :"FILTER", :"INFO"]

    attr_reader :cache, :path

    def initialize(file)
      @path = file
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
      file = File.open(@path, "r")
      while (file.pos < file.size)
        pos = file.pos
        line = file.readline
        if started
          if (isARow(line))
            row = VCFRow.new line
            row.filePosition = pos
            yield row
          end
        else
          started = isLineHeader(line)
        end
      end
      file.close
    end

    def load()
      if (Dir.exist? index_dir_name)
        return
      elsif (has_index_file)
        Dir.mkdir(index_dir_name)
        load_from_index
      else
        Dir.mkdir(index_dir_name)
        load_from_rows
      end
    end

    def load_from_rows
      self.each_row do |row|
        chr = row.chromosome.to_sym
        unless (@cache)
          @cache = createCacheFor(chr)
        end
        if (@cache.chromosome != chr)
          @cache.save
          @cache = createCacheFor(chr)
        end
        @cache[row.position] = row.filePosition
      end
      @cache.save
    end

    def load_from_index
      File.foreach(index_file_name) do |line|
        row = line.split
        chr = row[0].to_sym
        unless (@cache)
          @cache = createCacheFor(chr)
        end
        if (@cache.chromosome != chr)
          @cache.save
          @cache = createCacheFor(chr)
        end
        @cache[row[1].to_i] = row[2].to_i
      end
      @cache.save
    end

    def has_index_file
      File.exist? index_file_name
    end

    def index_file_name
      "#{File.dirname(path)}/#{File.basename(path)}.biolabi.index"
    end

    def index_dir_name
      "#{File.dirname(path)}/#{File.basename(path)}_biolabi"
    end

    def createCacheFor(chromosome)
      chrCache = ChrCache.new(chromosome, "#{index_dir_name}/#{chromosome}.idx")
      chrCache
    end

    def cacheFor(chromosome)
      if (@cache && @cache.chromosome == chromosome)
        @cache
      else
        @cache = createCacheFor(chromosome)
        @cache.load
        @cache
      end
    end

    def findRow(chrom, position)
      pos = cacheFor(chrom.to_sym)[position]
      if (pos)
        readPos(pos)
      else
        nil
      end
    end

    def readPos(pos)
      file = File.open(@path, "r")
      file.pos = pos
      row = VCFRow.new(file.readline)
      file.close
      row
    end
  end

  class VCFRow
    attr_reader :chromosome, :id, :position, :ref, :alt, :info, :raw
    attr_accessor :filePosition

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
