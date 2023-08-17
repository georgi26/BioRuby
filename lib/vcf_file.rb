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

  class VCFRow
    attr_reader :chromosome, :id, :position, :ref, :alt, :info, :raw
    attr_accessor :filePosition
    CLNSIG_TRANSLATION = [
      "Uncertain significance", "not provided", "Benign", "Likely benign",
      "Likely pathogenic", "Pathogenic", "Drug response", "Confers sensitivity",
      "Risk factor", "Association", "Protective",
      "Conflicting interpretations of pathogenicity", "Affects", "Association not found",
      "Benign/Likely benign", "Pathogenic/Likely pathogenic",
      "Conflicting data from submitters",
      "Pathogenic, low penetrance", "Likely pathogenic, low penetrance",
      "Established risk allele", "Likely risk allele",
      "Uncertain risk allele",
    ]

    def initialize(rawData)
      @raw = rawData
      self.parse
    end

    def mergeReference(refRow)
      @id = refRow.id
      @info.merge! refRow.info
    end

    def ac
      getInfoFirst(:AC)
    end

    def af
      getInfoFirst(:AF)
    end

    def vc
      getInfoFirst(:VC)
    end

    def to_s
      "#{chromosome} #{position} #{id} #{ref} #{alt} #{info}"
    end

    def to_json
      { chromosome: chromosome, position: position, id: id, ref: ref, alt: alt, info: info }.to_json
    end

    def to_clin_json
      { chromosome: chromosome, position: position, id: id, ref: ref, alt: alt, ac: ac, af: af, vc: vc, geninfo: geninfo, clndn: clndn.uniq, clnsig: clnsig.uniq }.to_json
    end

    def self.csv_header
      "'chromosome','position','id','ref','alt','ac','af','vc','geninfo','clndn','clnsig','max_clnsig'"
    end

    def to_csv
      "'#{chromosome}','#{position}','#{id}','#{ref}','#{alt}','#{ac}','#{af}','#{vc}','#{geninfo}','#{clndn_csv}','#{clnsig_translated_csv}','#{maxCLNSIG}'"
    end

    def freq
      @info[:FREQ] || []
    end

    def clnsig
      @info[:CLNSIG] || []
    end

    def clnsig_translated
      clnsig.map do |cln|
        CLNSIG_TRANSLATION[cln.to_i]
      end
    end

    def freqFor(state, allele)
      index = allels.index(allele)
      if (index)
        result = freq[state][index] || 0
        result.to_f
      else
        0
      end
    end

    def allels
      result = []
      if (ref.is_a? Array)
        result = [*ref]
      else
        result.push(ref)
      end

      if (alt.is_a? Array)
        result = [*result, *alt]
      else
        result.push(alt)
      end
      result
    end

    def clndn
      @info[:CLNDN] || []
    end

    def clndn_csv
      clndn.to_s.gsub("\"", "|")
    end

    def clnsig_translated_csv
      clnsig_translated.to_s.gsub("\"", "|")
    end

    def geninfo
      getInfoFirst(:GENEINFO)
    end

    def getInfoFirst(key)
      result = @info[key]
      if (result.is_a?(Array) && result.size == 1)
        result = result.first
      end
      result
    end

    def clndnMost
      most = ""
      mostCount = 0
      if (clndn.is_a? Array)
        clndn.each do |c|
          if (c != most)
            cCount = clndn.filter { |cc| cc == c }.count
            if (cCount > mostCount)
              mostCount = cCount
              most = c
            end
          end
        end
      end

      most
    end

    def maxCLNSIG
      max = 0
      cln = clnsig
      if (cln.is_a? Array)
        cln.each do |c|
          i = c.to_i
          if (i > max)
            max = i
          end
        end
      end
      max
    end

    def parse()
      tokens = @raw.split
      @chromosome = VCFFile::ASSEMBLY_REPORT[tokens[0]]
      @position = tokens[1].to_i
      @id = tokens[2]
      @ref = tokens[3]
      @alt = tokens[4].split(",")
      @alt = @alt[0] if @alt.size == 1
      @info = parseInfo(tokens[7])
    end

    def parseInfo(input)
      result = {}
      rows = input.split(";")
      rows.each do |r|
        rr = r.split("=")
        if (rr.size >= 2)
          key = rr[0].to_sym
          if (key == :FREQ)
            result[key] = parseFreq(rr[1])
          else
            values = rr[1].split ","
            result[key] = mergeValues(values)
          end
        end
      end
      result
    end

    def mergeValues(values)
      result = []
      values.each do |v|
        vvs = v.split("|")
        result.push *vvs
      end
      result
    end

    def parseFreq(data)
      result = {}
      frequencies = data.split("|")
      frequencies.each do |f|
        kv = f.split(":")
        if (kv.size == 2)
          result[kv[0]] = kv[1].split(",")
        else
          raise "Error parse frequency"
        end
      end
      result
    end
  end
end
