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
      class1 = "#{fixtures}/JavaOK.class"
      class2 = "#{fixtures}/JavaFailed.class"

      it 'has not yet compiled' do
        FileUtils.rm_f(class1)
        FileUtils.rm_f(class2)
        expect(File).not_to exist(class1)
        expect(File).not_to exist(class2)
      end

      ok = {}
      failed = {}

      it 'compiles files' do
        ok = described_class.java("#{fixtures}/JavaOK.java")
        failed = described_class.java("#{fixtures}/JavaFailed.java")
        expect(File).to exist(class1)
        expect(File).to exist(class2)
      end

      context 'when file is valid' do
        it('runs successfully') { expect(ok[:exitcode]).to be_zero }
        it('has something in stdout') { expect(ok[:stdout]).not_to be_blank }
        it('has nothing in stderr') { expect(ok[:stderr]).to be_blank }
      end

      context 'when file is invalid' do
        it('runs failed') { expect(failed[:exitcode]).not_to be_zero }
        it('has nothing in stdout') { expect(failed[:stdout]).to be_blank }
        it('has something in stdout') { expect(failed[:stderr]).not_to be_blank }
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
