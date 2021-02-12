# frozen_string_literal: true

describe JDK do
  fixtures = 'spec/fixtures/jdk'
  before(:all) { Dir.glob("#{fixtures}/**/*.class").each { |f| File.delete(f) } }

  describe '.javac' do
    context 'when file has no error' do
      Dir.glob("#{fixtures}/wce/compile/valid/*.java").each do |file|
        capture = described_class.javac(file)
        it('stdout is empty') { expect(capture.stdout).to be_blank }
        it('stderr is empty') { expect(capture.stderr).to be_blank }
        it('returns zero') { expect(capture.exitstatus).to be_zero }
      end
    end

    context 'when file has errors' do
      Dir.glob("#{fixtures}/wce/compile/invalid/*.java").each do |file|
        capture = described_class.javac(file)
        it('stdout is empty') { expect(capture.stdout).to be_blank }
        it('stderr is not empty') { expect(capture.stderr).not_to be_blank }
        it('returns non-zero') { expect(capture.exitstatus).not_to be_zero }
      end
    end

    context 'when file is not a java file' do
      it 'raises Helli::UnsupportedFileTypeError' do
        expect(described_class.javac("#{fixtures}/misc/NotJava.txt").exitstatus).not_to be_zero
      end
    end

    context 'when file does not exist' do
      it 'raises Errno::ENOENT' do
        filename = 'What.java'
        raise "remove /#{filename} to run this test" if File.exist?(filename)

        expect { described_class.javac(filename) }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe '.java' do
    context 'when file has no error' do
      Dir.glob("#{fixtures}/wce/execute/valid/*.java").each do |file|
        described_class.javac(file)
        captures = described_class.java(file)
        it('stdout is not empty') { expect(captures.stdout).not_to be_blank }
        it('stderr is empty') { expect(captures.stderr).to be_blank }
        it('returns zero') { expect(captures.exitstatus).to be_zero }
      end
    end

    context 'when file has errors' do
      Dir.glob("#{fixtures}/wce/execute/invalid/*.java").each do |file|
        described_class.javac(file)
        capture = described_class.java(file)
        it('stdout is empty') { expect(capture.stdout).to be_blank }
        it('stdout is not empty') { expect(capture.stderr).not_to be_blank }
        it('returns non-zero') { expect(capture.exitstatus).not_to be_zero }
      end
    end

    context 'when file is not a java file' do
      it 'raises Helli::UnsupportedFileTypeError' do
        expect(described_class.java("#{fixtures}/misc/NotJava.txt").exitstatus).not_to be_zero
      end
    end

    context 'when file does not exist' do
      it 'raises Errno::ENOENTError' do
        filename = 'What.java'
        raise "remove /#{filename} to run this test" if File.exist?(filename)

        expect { described_class.java(filename) }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe '.checkstyle' do
    context 'when file has no warnings' do
      Dir.glob("#{fixtures}/checkstyle/valid/*.java").each do |file|
        capture = described_class.checkstyle(file)
        it('stdout is not empty') { expect(capture.stdout).not_to be_blank }
        it('stderr is empty') { expect(capture.stderr).to be_blank }
        it('checkstyle successfully') { expect(capture.exitstatus).to be_zero }
      end
    end

    context 'when file has warnings' do
      Dir.glob("#{fixtures}/checkstyle/invalid/*.java").each do |file|
        capture = described_class.checkstyle(file)
        it('stdout is not empty') { expect(capture.stdout).not_to be_blank }
        it('stderr is empty') { expect(capture.stderr).to be_blank }
        it('checkstyle successfully') { expect(capture.exitstatus).to be_zero }
      end
    end
  end
end
