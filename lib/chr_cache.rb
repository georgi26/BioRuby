module BioLabi
  class ChrCache
    SIZE = 17
    MODE = "QQc"
    BUFFER = 1000000

    attr_reader :chromosome, :path

    attr_accessor :cache

    def initialize(chromosome, path)
      @chromosome = chromosome.to_sym
      @path = path
      @cache = Hash.new
    end

    def save
      file = nil
      if (File.exist? path)
        file = File.open(@path, "a")
      else
        file = File.open(@path, "w")
      end
      @cache.each do |k, v|
        buffer = [k.to_i, v.to_i, 0].pack MODE
        file.write buffer
      end
      file.flush
      file.close
    end

    def load
      @cache = Hash.new
      file = File.open(@path, "r")
      size = SIZE * BUFFER
      mode = MODE * BUFFER
      while (buffer = file.read(size))
        if (buffer.size < size)
          mode = MODE * (buffer.size / SIZE)
        end
        arr = buffer.unpack(mode)
        index = 0
        arrSize = arr.size
        while (index < arrSize)
          a = arr[index]
          unless a
            index = index + 1
            break
          end
          if (a && a == 0)
            @cache[arr[index - 2]] = arr[index - 1]
          end
          index = index + 1
        end
      end
      file.close
    end

    def [](position)
      @cache[position.to_i]
    end

    def []=(position, filePosition)
      @cache[position.to_i] = filePosition.to_i
    end
  end
end
