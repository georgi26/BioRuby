require "minitest/autorun"
require_relative "../lib/bioruby.rb"

describe BioLabi::VCFRow do
  before do
    @vcfRow = BioLabi::VCFRow.new("NC_000001.10    10001   rs1570391677    T       A,C     .       .       RS=1570391677;dbSNPBuildID=154;SSR=0;PSEUDOGENEINFO=DDX11L1:100287102;VC=SNV;R5;GNO;
        FREQ=KOREAN:0.9891,0.0109,.|SGDP_PRJ:0,1,.|dbGaP_PopFreq:1,.,0;COMMON")
  end
  describe "When given vcf raw data line from vcf file" do
    it "Must read Chomosome number correctly" do
      _(@vcfRow.chromosome).must_equal :"1"
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
      _(@vcfRow.alt).must_equal ["A", "C"]
    end
  end

  describe "When given row with CLNSIG=5" do
    it "must read correct clnsig and clndn" do
      row = BioLabi::VCFRow.new("NC_012920.1     960     rs1556422499    CT      CCC,CCCC,CCCCC,CCCCCC,CCCCCCC,CCCCCCCC  .       .       RS=1556422499;SSR=0;VC=INDEL;CLNVI=OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002,OMIM:561000.0002;CLNORIGIN=1,1,1,1,1,1,1;CLNSIG=5,5,5,5,5,5,5;CLNDISDB=GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000,GeneReviews:NBK1422/MONDO:MONDO:0010799/MedGen:C1838854/Orphanet:168609/OMIM:580000;CLNDN=Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness,Aminoglycoside-induced_deafness;CLNREVSTAT=no_criteria,no_criteria,no_criteria,no_criteria,no_criteria,no_criteria,no_criteria;CLNACC=RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2,RCV000010257.2;CLNHGVS=NC_012920.1:m.961=,NC_012920.1:m.961delinsCC,NC_012920.1:m.961delinsCCC,NC_012920.1:m.961delinsCCCC,NC_012920.1:m.961delinsCCCCC,NC_012920.1:m.961delinsCCCCCC,NC_012920.1:m.961delinsCCCCCC")
      assert_equal ["5", "5", "5", "5", "5", "5", "5"], row.clnsig
      assert_equal ["Aminoglycoside-induced_deafness", "Aminoglycoside-induced_deafness",
                    "Aminoglycoside-induced_deafness", "Aminoglycoside-induced_deafness", "Aminoglycoside-induced_deafness",
                    "Aminoglycoside-induced_deafness", "Aminoglycoside-induced_deafness"], row.clndn
      assert_equal 5, row.maxCLNSIG
      assert_equal "Aminoglycoside-induced_deafness", row.clndnMost
    end
  end

  describe "parseInfo should parse info with | separator and also parse FREQ" do
    before do
      @row = BioLabi::VCFRow.new "NC_000001.10    11850750        rs35737219      G       A       .       .       RS=35737219;dbSNPBuildID=126;SSR=0;GENEINFO=MTHFR:4524;VC=SNV;PUB;NSM;GNO;FREQ=1000Genomes:0.9956,0.004372|ALSPAC:0.9756,0.02439|Estonian:0.9922,0.007812|ExAC:0.986,0.01395|FINRISK:0.9901,0.009868|GENOME_DK:0.975,0.025|GnomAD:0.9854,0.01462|GnomAD_exomes:0.9863,0.01366|GoESP:0.9815,0.01845|GoNL:0.9699,0.03006|KOREAN:0.999,0.001027|MGP:0.9813,0.01873|NorthernSweden:0.97,0.03|PAGE_STUDY:0.9928,0.00723|PRJEB37584:0.9987,0.001263|PRJEB37766:0.9909,0.009107|PharmGKB:0.9833,0.01668|Qatari:0.9954,0.00463|SGDP_PRJ:0.5,0.5|Siberian:0.5,0.5|TOPMED:0.9856,0.0144|TWINSUK:0.9795,0.0205|dbGaP_PopFreq:0.9786,0.02139;COMMON;CLNVI=.,ARUP_Laboratories\x2c_Molecular_Genetics_and_Genomics\x2cARUP_Laboratories:108838|UniProtKB:P42898#VAR_018860;CLNORIGIN=.,1;CLNSIG=.,2|2|2|2;CLNDISDB=.,MedGen:CN169374|Office_of_Rare_Diseases:2734/MONDO:MONDO:0009353/MedGen:C1856058/Orphanet:395/OMIM:236250|MedGen:CN517202|MedGen:C4017062;CLNDN=.,not_specified|Homocystinuria_due_to_methylene_tetrahydrofolate_reductase_deficiency|not_provided|Homocystinuria_due_to_MTHFR_deficiency;CLNREVSTAT=.,single|mult|mult|no_criteria;CLNACC=.,RCV000261696.8|RCV000534228.8|RCV000755305.8|RCV001273142.2;CLNHGVS=NC_000001.10:g.11850750=,NC_000001.10:g.11850750G>A"
    end

    it "Must read merge clnsig CLNSIG=.,2|2|2|2 into [0,2,2,2,2]" do
      assert_equal [".", "2", "2", "2", "2"], @row.clnsig
    end

    it "Must generate csv header" do
      assert_equal "'chromosome','position','id','ref','alt','ac','af','vc','geninfo','clndn','clnsig','max_clnsig'",
                   BioLabi::VCFRow.csv_header
    end

    it "Must convert row to csv" do
      expected = "'1','11850750','rs35737219','G','A','','','SNV','MTHFR:4524','[|.|, |not_specified|, |Homocystinuria_due_to_methylene_tetrahydrofolate_reductase_deficiency|, |not_provided|, |Homocystinuria_due_to_MTHFR_deficiency|]','[|Uncertain significance|, |Benign|, |Benign|, |Benign|, |Benign|]','2'"
      assert_equal expected, @row.to_csv
    end

    it "Freq must equal" do
      expected = { "1000Genomes" => ["0.9956", "0.004372"], "ALSPAC" => ["0.9756", "0.02439"],
                   "Estonian" => ["0.9922", "0.007812"], "ExAC" => ["0.986", "0.01395"], "FINRISK" => ["0.9901", "0.009868"],
                   "GENOME_DK" => ["0.975", "0.025"], "GnomAD" => ["0.9854", "0.01462"], "GnomAD_exomes" => ["0.9863", "0.01366"],
                   "GoESP" => ["0.9815", "0.01845"], "GoNL" => ["0.9699", "0.03006"], "KOREAN" => ["0.999", "0.001027"],
                   "MGP" => ["0.9813", "0.01873"], "NorthernSweden" => ["0.97", "0.03"], "PAGE_STUDY" => ["0.9928", "0.00723"],
                   "PRJEB37584" => ["0.9987", "0.001263"], "PRJEB37766" => ["0.9909", "0.009107"], "PharmGKB" => ["0.9833", "0.01668"],
                   "Qatari" => ["0.9954", "0.00463"], "SGDP_PRJ" => ["0.5", "0.5"], "Siberian" => ["0.5", "0.5"],
                   "TOPMED" => ["0.9856", "0.0144"], "TWINSUK" => ["0.9795", "0.0205"],
                   "dbGaP_PopFreq" => ["0.9786", "0.02139"] }
      assert_equal expected, @row.freq
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
      row = @vcfFile.findRow("1", 10032)
      assert row
      assert_equal :"1", row.chromosome
      assert_equal 10032, row.position
    end
  end
end

describe BioLabi::AssemblyReport do
  before do
    @aReport = BioLabi::AssemblyReport.new
  end
  describe "When given GenBank-Accn or RefSeq-Accn" do
    it "Must return correct chromosome number " do
      assert_equal :"1", @aReport["NC_000001.10"]
      assert_equal :"11", @aReport["NC_000011.9"]
      #assert_equal :"1", @aReport["NW_004070863.1"]
      #assert_equal :"7", @aReport["NW_003571039.1"]
      #assert_equal :"X", @aReport["NW_004070883.1"]
      assert_equal :"MT", @aReport["NC_012920.1"]
      #assert_equal :"17", @aReport["GL000258.1"]
    end
  end
end

describe "Find Frequency for Given allel" do
  before do
    data = "NC_000001.10    961827  rs3121556       G       A,T     .       .       RS=3121556;dbSNPBuildID=103;SSR=0;GENEINFO=AGRN:375790;VC=SNV;INT;R5;GNO;FREQ=1000Genomes:0.1721,0.8279,.|ALSPAC:0.08381,0.9162,.|Estonian:0.05536,0.9446,.|GENOME_DK:0.05,0.95,.|GnomAD:0.1783,0.8217,.|GoNL:0.0521,0.9479,.|KOREAN:0.04369,0.9563,0|Korea1K:0.03384,0.9662,.|NorthernSweden:0.1233,0.8767,.|Qatari:0.1806,0.8194,.|SGDP_PRJ:0.09023,0.9098,.|Siberian:0.05357,0.9464,.|TOMMO:0.02997,0.97,.|TOPMED:0.1832,0.8168,.|TWINSUK:0.07956,0.9204,.|Vietnamese:0.00463,0.9954,.|dbGaP_PopFreq:0.1292,0.8708,.;COMM"
    @row = BioLabi::VCFRow.new(data)
  end
  it "Must diplay frequency for given allele" do
    assert_equal 0.9446, @row.freqFor("Estonian", "A")
    assert_equal 0.05536, @row.freqFor("Estonian", "G")
    assert_equal 0, @row.freqFor("Estonian", "T")
    assert_equal 0.9563, @row.freqFor("KOREAN", "A")
    assert_equal 0.04369, @row.freqFor("KOREAN", "G")
    assert_equal 0, @row.freqFor("KOREAN", "T")
  end
end
