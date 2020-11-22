describe Helli::Command::Java do
  fixtures = 'spec/fixtures/java'
  before(:all) { Dir.glob("#{fixtures}/**/*.class").each { |f| File.delete(f) } }

  describe '.javac' do
    context 'when file is valid' do
      Dir.glob("#{fixtures}/wce/compile/valid/*.java").each do |file|
        process = described_class.javac(file)
        it('javac successfully') { expect(process.exitstatus).to be_zero }
        it('stdout is empty') { expect(process.stdout).to be_blank }
        it('stderr is empty') { expect(process.stderr).to be_blank }
      end
    end

    context 'when file is invalid' do
      Dir.glob("#{fixtures}/wce/compile/invalid/*.java").each do |file|
        process = described_class.javac(file)
        it('javac failed') { expect(process.exitstatus).not_to be_zero }
        it('stdout is empty') { expect(process.stdout).to be_blank }
        it('stderr is not empty') { expect(process.stderr).not_to be_blank }
      end
    end
  end

  describe '.java' do
    context 'when file is valid' do
      Dir.glob("#{fixtures}/wce/execute/valid/*.java").each do |file|
        described_class.javac(file)
        process = described_class.java(file)
        it('java successfully') { expect(process.exitstatus).to be_zero }
        it('stdout is not empty') { expect(process.stdout).not_to be_blank }
        it('stderr is empty') { expect(process.stderr).to be_blank }
      end
    end

    context 'when file is invalid' do
      Dir.glob("#{fixtures}/wce/execute/invalid/*.java").each do |file|
        described_class.javac(file)
        process = described_class.java(file)
        it('java failed') { expect(process.exitstatus).not_to be_zero }
        it('stdout is empty') { expect(process.stdout).to be_blank }
        it('stdout is not empty') { expect(process.stderr).not_to be_blank }
      end
    end
  end

  describe '.checkstyle' do
    context 'when file has no warnings' do
      Dir.glob("#{fixtures}/checkstyle/valid/*.java").each do |file|
        process = described_class.checkstyle(file)
        it('checkstyle successfully') { expect(process.exitstatus).to be_zero }
        it('stdout is not empty') { expect(process.stdout).not_to be_blank }
        it('stderr is empty') { expect(process.stderr).to be_blank }
      end
    end

    context 'when file has warnings' do
      Dir.glob("#{fixtures}/checkstyle/invalid/*.java").each do |file|
        process = described_class.checkstyle(file)
        it('checkstyle successfully') { expect(process.exitstatus).to be_zero }
        it('stdout is not empty') { expect(process.stdout).not_to be_blank }
        it('stderr is empty') { expect(process.stderr).to be_blank }
      end
    end
  end
end
