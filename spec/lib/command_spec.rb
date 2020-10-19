describe Command do
  describe Command::Java do
    fixtures = 'spec/fixtures/java'
    Dir.glob("#{fixtures}/*.class").each { |f| File.delete(f) }

    describe '.javac' do
      context 'when file is valid' do
        o = described_class.javac("#{fixtures}/JavacOK.java")

        it('compiles successfully') { expect(o[:exitcode]).to be_zero }
        it('has nothing in stdout') { expect(o[:stdout]).to be_blank }
        it('has nothing in stderr') { expect(o[:stderr]).to be_blank }
      end

      context 'when file is invalid' do
        o = described_class.javac("#{fixtures}/JavacFailed.java")

        it('compiles failed') { expect(o[:exitcode]).not_to be_zero }
        it('has nothing in stdout') { expect(o[:stdout]).to be_blank }
        it('has something in stderr') { expect(o[:stderr]).not_to be_blank }
      end
    end

    describe '.java' do
      context 'when file is valid' do
        described_class.javac("#{fixtures}/JavaOK.java")
        o = described_class.java("#{fixtures}/JavaOK.java")

        it('runs successfully') { expect(o[:exitcode]).to be_zero }
        it('has something in stdout') { expect(o[:stdout]).not_to be_blank }
        it('has nothing in stderr') { expect(o[:stderr]).to be_blank }
      end

      context 'when file is invalid' do
        described_class.javac("#{fixtures}/JavaFailed.java")
        o = described_class.java("#{fixtures}/JavaFailed.java")

        it('runs failed') { expect(o[:exitcode]).not_to be_zero }
        it('has nothing in stdout') { expect(o[:stdout]).to be_blank }
        it('has something in stdout') { expect(o[:stderr]).not_to be_blank }
      end

      context 'when file is not compiled' do
        it 'raises CompileError' do
          FileUtils.rm_f("#{fixtures}/JavaOK.class")
          expect { described_class.java("#{fixtures}/JavaOK.java") }
            .to raise_error(described_class::CompileError)
        end
      end
    end

    describe '.checkstyle' do
      ok = described_class.checkstyle("#{fixtures}/CheckstyleOK.java")
      failed = described_class.checkstyle("#{fixtures}/CheckstyleWarnings.java")

      context 'when file has no warnings' do
        it('runs successfully') { expect(ok[:exitcode]).to be_zero }
        it('has something in stdout') { expect(ok[:stdout]).not_to be_blank }
        it('has nothing in stderr') { expect(ok[:stderr]).to be_blank }
      end

      context 'when file has warnings' do
        it('runs successfully') { expect(failed[:exitcode]).to be_zero }
        it('has something in stdout') { expect(failed[:stdout]).not_to be_blank }
        it('has nothing in stderr') { expect(failed[:stderr]).to be_blank }
      end

      it('shows warnings in stdout instead of stderr') { expect(ok[:stdout]).not_to eq(failed[:stdout]) }
    end
  end
end
