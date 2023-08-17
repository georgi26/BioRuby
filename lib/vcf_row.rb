module BioLabi
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
