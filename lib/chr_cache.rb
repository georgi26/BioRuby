module BioLabi
  class ChrCache
    SIZE = 17
    MODE = "QQc"
    BUFFER = 1000000
    B_SEARCH_BUFFER = 1000000

    attr_reader :chromosome, :path

    attr_accessor :cache

    def initialize(chromosome, path)
      @chromosome = chromosome.to_sym
      @path = path
      @cache = Hash.new
    end

    def sortFile()
      LOGGER.debug("Start sortFile ChrCache for #{path}")
      load
      File.delete path
      save
      LOGGER.debug("Done sorting ChrCache for #{path}")
    end

    def save
      LOGGER.debug("Start save ChrCache for #{path}")
      file = nil
      if (File.exist? path)
        file = File.open(@path, "a")
      else
        file = File.open(@path, "w")
      end
      LOGGER.debug("Start sort hash #{path}")
      sortedCache = @cache.sort
      LOGGER.debug("End sort hash #{path}")
      topBuffer = ""
      sortedCache.each do |entry|
        buffer = [entry[0].to_i, entry[1].to_i, 0].pack MODE
        topBuffer << buffer
        if (topBuffer.size > BUFFER)
          file.write topBuffer
          topBuffer.clear
        end
      end
      file.write topBuffer
      file.flush
      file.close
      LOGGER.debug("Done Save ChrCache for #{path}")
    end

    def load
      LOGGER.debug("Start Load ChrCache for #{path}")
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
      LOGGER.debug("Done Load ChrCache for #{path}")
    end

    def [](position)
      @cache[position.to_i]
    end

    def []=(position, filePosition)
      @cache[position.to_i] = filePosition.to_i
    end

    def binSearch(position)
      file = File.open(@path, "r")
      found = binSearchBetween(position.to_i, 0, file.size, file)
      file.close
      found
    end

    def binSearchBetween(position, startPos, endPos, file)
      if ((endPos - startPos) < B_SEARCH_BUFFER)
        return searchBetween(position, startPos, endPos, file)
      end
      LOGGER.debug "start #{startPos} end #{endPos}"
      middle = findMiddlePos(startPos, endPos)
      data = readAt(middle, file)
      if (data[0].to_i == position)
        return data[1].to_i
      elsif (data[0].to_i > position)
        return binSearchBetween(position, startPos, middle, file)
      else
        return binSearchBetween(position, middle, endPos, file)
      end
    end

    def findMiddlePos(startPos, endPos)
      sizePoz = endPos - startPos
      blockCount = sizePoz / SIZE
      middle = blockCount / 2
      middlePos = middle * SIZE
      startPos + middlePos
    end

    def readAt(pos, file)
      file.pos = pos
      block = file.read(SIZE)
      data = block.unpack MODE
      data
    end

    def searchBetween(position, startPos, endPos, file)
      file.pos = startPos
      size = SIZE * B_SEARCH_BUFFER
      mode = MODE * B_SEARCH_BUFFER
      while (file.pos < endPos)
        buffer = file.read(size)
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
          if (a && a == 0 && arr[index - 2].to_i == position)
            return arr[index - 1]
          end
          index = index + 1
        end
      end
      nil
    end

    def size
      @cache.size
    end
  end
end
