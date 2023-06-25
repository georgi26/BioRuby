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

  describe "When given row with CLNSIG=5" do
    it "must read correct clnsig" do
      row = BioLabi::VCFRow.new("NC_012920.1     960     rs1556422499    CT      CCC,CCCC,CCCCC,CCCCCC,CCCCCCC,CCCCCCCC  .       .       RS=1556422499;SSR=0;VC=INDEL;CLNVI=OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002;CLNORIGIN=1,1,1,1,1,1,1;CLNSIG=5,5,5,5,5,5,5;CLNDISDB=GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000;CLNDN=Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness;CLNREVSTAT=no_criteria,no_criteria,no_criteria,no_criteria,no_criteria,no_criteria,no_criteria;CLNACC=RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2;CLNHGVS=NC_012920.1:m.961=,NC_012920.1:m.961delinsCC,NC_012920.1:m.961delinsCCC,NC_012920.1:m.961delinsCCCC,NC_012920.1:m.961delinsCCCCC,NC_012920.1:m.961delinsCCCCCC,NC_012920.1:m.961delinsCCCCCC")
      assert_equal 5, row.clnsig
    end
  end
end

describe BioLabi::VCFFile do
  before do
    @vcfFile = BioLabi::VCFFile.new("#{File.dirname(__FILE__)}/test.vcf")
  end

  describe "When read vcf file" do
    it "Has to check if row of vcf file is a row " do
      row = "NC_000001.10    10001   rs1570391677    T       A,C     .       .       RS=1570391677;dbSNPBuildID=154;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=SNV;R5;GNO;
      FREQ=KOREAN:0.9891,0.0109,.|SGDP_PRJ:0,1,.|dbGaP_PopFreq:1,.,0;COMMON"
      assert @vcfFile.isARow(row)
    end

    it "Has to recognize header row" do
      header = "#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO"
      assert @vcfFile.isLineHeader(header)
    end

    it "Has to read rows from file" do
      result = []
      @vcfFile.each_row do |row|
        result.push(row)
      end
      assert_equal 30, result.size
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

describe BioLabi::AssemblyReport do
  before do
    @aReport = BioLabi::AssemblyReport.new
  end
  describe "When given GenBank-Accn or RefSeq-Accn" do
    it "Must return correct chromosome number " do
      assert_equal "1", @aReport.chromosomes_map["NC_000001.10"]
      assert_equal "11", @aReport.chromosomes_map["GL000202.1"]
      assert_equal "1", @aReport.chromosomes_map["NW_004070863.1"]
      assert_equal "7", @aReport.chromosomes_map["NW_003571039.1"]
      assert_equal "X", @aReport.chromosomes_map["NW_004070883.1"]
      assert_equal "MT", @aReport.chromosomes_map["NC_012920.1"]
      assert_equal "17", @aReport.chromosomes_map["GL000258.1"]
    end
  end
end
