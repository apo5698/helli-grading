describe Command do
  describe Command::Java do
    fixtures = 'spec/fixtures/java'

    describe '.javac' do
      context 'when file is valid' do
        o = Command::Java.javac("#{fixtures}/JavacOK.java")

        it('compiles successfully') { expect(o[:exitcode]).to be_zero }
        it('has nothing in stdout') { expect(o[:stdout]).to be_blank }
        it('has nothing in stderr') { expect(o[:stderr]).to be_blank }
      end

      context 'when file is invalid' do
        o = Command::Java.javac("#{fixtures}/JavacFailed.java")

        it('compiles failed') { expect(o[:exitcode]).not_to be_zero }
        it('has nothing in stdout') { expect(o[:stdout]).to be_blank }
        it('has something in stderr') { expect(o[:stderr]).not_to be_blank }
      end
    end

    describe '.java' do
      context 'when file is valid' do
        o = Command::Java.java("#{fixtures}/JavaOK.java")

        it('runs successfully') { expect(o[:exitcode]).to be_zero }
        it('has something in stdout') { expect(o[:stdout]).not_to be_blank }
        it('has nothing in stderr') { expect(o[:stderr]).to be_blank }
      end

      context 'when file is invalid' do
        o = Command::Java.java("#{fixtures}/JavaFailed.java")

        it('runs failed') { expect(o[:exitcode]).not_to be_zero }
        it('has nothing in stdout') { expect(o[:stdout]).to be_blank }
        it('has something in stdout') { expect(o[:stderr]).not_to be_blank }
      end
    end

    describe '.checkstyle' do
      ok = Command::Java.checkstyle("#{fixtures}/CheckstyleOK.java")

      failed = Command::Java.checkstyle("#{fixtures}/CheckstyleWarnings.java")

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