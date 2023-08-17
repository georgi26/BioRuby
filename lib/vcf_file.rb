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
        if (@cache && !@cache.loaded)
          @cache.cancelLoad
        end
        @cache = createCacheFor(chromosome)
        @cache.loadAsync
        @cache
      end
    end

    def findRow(chrom, position)
      pos = nil
      chromCache = cacheFor(chrom.to_sym)
      if (chromCache.loaded)
        pos = chromCache[position]
      else
        pos = chromCache.binSearch(position)
      end
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
end
