describe Helli::Command::Java do
  fixtures = 'spec/fixtures/java'
  before(:all) { Dir.glob("#{fixtures}/**/*.class").each { |f| File.delete(f) } }

  describe '.javac' do
    context 'when file has no error' do
      Dir.glob("#{fixtures}/wce/compile/valid/*.java").each do |file|
        process = described_class.javac(file)
        it('returns zero') { expect(process.exitstatus).to be_zero }
        it('stdout is empty') { expect(process.stdout).to be_blank }
        it('stderr is empty') { expect(process.stderr).to be_blank }
      end
    end

    context 'when file has errors' do
      Dir.glob("#{fixtures}/wce/compile/invalid/*.java").each do |file|
        process = described_class.javac(file)
        it('returns non-zero') { expect(process.exitstatus).not_to be_zero }
        it('stdout is empty') { expect(process.stdout).to be_blank }
        it('stderr is not empty') { expect(process.stderr).not_to be_blank }
      end
    end

    context 'when file is not a java file' do
      it 'raises Helli::UnsupportedFileTypeError' do
        expect { described_class.javac("#{fixtures}/misc/NotJava.txt") }.to raise_error(Helli::UnsupportedFileTypeError)
      end
    end

    context 'when file does not exist' do
      it 'raises Helli::FileNotFoundError' do
        filename = 'What.java'
        raise "remove /#{filename} to run this test" if File.exist?(filename)

        expect { described_class.javac(filename) }.to raise_error(Helli::FileNotFoundError)
      end
    end
  end

  describe '.java' do
    context 'when file has no error' do
      Dir.glob("#{fixtures}/wce/execute/valid/*.java").each do |file|
        described_class.javac(file)
        process = described_class.java(file)
        it('returns zero') { expect(process.exitstatus).to be_zero }
        it('stdout is not empty') { expect(process.stdout).not_to be_blank }
        it('stderr is empty') { expect(process.stderr).to be_blank }
      end
    end

    context 'when file has errors' do
      Dir.glob("#{fixtures}/wce/execute/invalid/*.java").each do |file|
        described_class.javac(file)
        process = described_class.java(file)
        it('returns non-zero') { expect(process.exitstatus).not_to be_zero }
        it('stdout is empty') { expect(process.stdout).to be_blank }
        it('stdout is not empty') { expect(process.stderr).not_to be_blank }
      end
    end

    context 'when file has not been compiled' do
      Dir.glob("#{fixtures}/wce/execute/valid/*.java").each do |file|
        it 'raises Helli::FileNotFoundError' do
          expect { described_class.java(file) }.to raise_error(Helli::Command::Java::ClassFileNotFoundError)
        end
      end
    end

    context 'when file is not a java file' do
      it 'raises Helli::UnsupportedFileTypeError' do
        expect { described_class.java("#{fixtures}/misc/NotJava.txt") }.to raise_error(Helli::UnsupportedFileTypeError)
      end
    end

    context 'when file does not exist' do
      it 'raises Helli::FileNotFoundError' do
        filename = 'What.java'
        raise "remove /#{filename} to run this test" if File.exist?(filename)

        expect { described_class.java(filename) }.to raise_error(Helli::FileNotFoundError)
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
