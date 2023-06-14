require "minitest/autorun"
require_relative "../lib/vcf_file.rb"

describe BioLabi::VCFRow do
  before do
    @vcfRow = BioLabi::VCFRow.new("NC_000001.10    10001   rs1570391677    T       A,C     .       .       RS=1570391677;dbSNPBuildID=154;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=SNV;R5;GNO;
        FREQ=KOREAN:0.9891,0.0109,.|SGDP_PRJ:0,1,.|dbGaP_PopFreq:1,.,0;COMMON")
  end
  describe "When given vcf raw data line from vcf file" do
    it "Must read Chomosome number correctly" do
      _(@vcfRow.chromosome).must_equal "1"
    end
    it "must read position number correctly" do
      _(@vcfRow.position).must_equal 10001
    end
    it "must read id correctly" do
      _(@vcfRow.id).must_equal "rs1570391677"
    end
    it "must read ref correctly" do
      _(@vcfRow.ref).must_equal "T"
    end
    it "must read alt correctly" do
      _(@vcfRow.alt).must_equal "A,C"
    end
  end
end

describe BioLabi::VCFFile do
  before do
    @vcfFile = BioLabi::VCFFile.new("./test.vcf")
  end

  describe "When read vcf file" do
    it "Has to read rows from file" do
      result = []
      @vcfFile.each_row do |row|
        result.push(row)
      end
      assert_equal 29, result.size
    end
    it "Has to find row by chromosome and position " do
      @vcfFile.load
      row = @vcfFile.findRow("1", 10031)
      assert row
      assert_equal "1", row.chromosome
      assert_equal 10031, row.position
    end
  end
end
