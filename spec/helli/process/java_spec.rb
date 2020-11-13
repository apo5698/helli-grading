describe Helli::Process::Java do
  fixtures = 'spec/fixtures/java'
  before(:all) { Dir.glob("#{fixtures}/**/*.class").each { |f| File.delete(f) } }

  describe '.javac' do
    context 'when file is valid' do
      Dir.glob("#{fixtures}/wce/compile/valid/*.java").each do |file|
        result = described_class.javac(file)
        it('javac successfully') { expect(result[:exitstatus]).to be_zero }
        it('stdout is empty') { expect(result[:stdout]).to be_blank }
        it('stderr is empty') { expect(result[:stderr]).to be_blank }
      end
    end

    context 'when file is invalid' do
      Dir.glob("#{fixtures}/wce/compile/invalid/*.java").each do |file|
        result = described_class.javac(file)
        it('javac failed') { expect(result[:exitstatus]).not_to be_zero }
        it('stdout is empty') { expect(result[:stdout]).to be_blank }
        it('stderr is not empty') { expect(result[:stderr]).not_to be_blank }
      end
    end
  end

  describe '.java' do
    context 'when file is valid' do
      Dir.glob("#{fixtures}/wce/execute/valid/*.java").each do |file|
        described_class.javac(file)
        result = described_class.java(file)
        it('java successfully') { expect(result[:exitstatus]).to be_zero }
        it('stdout is not empty') { expect(result[:stdout]).not_to be_blank }
        it('stderr is empty') { expect(result[:stderr]).to be_blank }
      end
    end

    context 'when file is invalid' do
      Dir.glob("#{fixtures}/wce/execute/invalid/*.java").each do |file|
        described_class.javac(file)
        result = described_class.java(file)
        it('java failed') { expect(result[:exitstatus]).not_to be_zero }
        it('stdout is empty') { expect(result[:stdout]).to be_blank }
        it('stdout is not empty') { expect(result[:stderr]).not_to be_blank }
      end
    end

    context 'when file is not compiled' do
      Dir.glob("#{fixtures}/wce/**/*.java").each do |file|
        it 'raises FileNotFoundError' do
          expect { described_class.java(file) }.to raise_error(Helli::FileNotFoundError)
        end
      end
    end
  end

  describe '.checkstyle' do
    context 'when file has no warnings' do
      Dir.glob("#{fixtures}/checkstyle/valid/*.java").each do |file|
        result = described_class.checkstyle(file)
        it('checkstyle successfully') { expect(result[:exitstatus]).to be_zero }
        it('stdout is not empty') { expect(result[:stdout]).not_to be_blank }
        it('stderr is empty') { expect(result[:stderr]).to be_blank }
      end
    end

    context 'when file has warnings' do
      Dir.glob("#{fixtures}/checkstyle/invalid/*.java").each do |file|
        result = described_class.checkstyle(file)
        it('checkstyle successfully') { expect(result[:exitstatus]).to be_zero }
        it('stdout is not empty') { expect(result[:stdout]).not_to be_blank }
        it('stderr is empty') { expect(result[:stderr]).to be_blank }
      end
    end
  end
end
