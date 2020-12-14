# frozen_string_literal: true

describe Helli::Attachment do
  url = 'https://github.com/apo5698/ags/raw/master/spec/fixtures/test_files/16bytes.bin'
  dest = 'spec/fixtures/test_files/test'

  before do
    FileUtils.rm_rf(dest) if Dir.exist?(dest)
    FileUtils.mkdir_p(dest)
  end

  after do
    FileUtils.rm_rf(dest) if Dir.exist?(dest)
  end

  describe '.download_from_url' do
    context 'when file does not exist' do
      it 'downloads file' do
        path = described_class.download_from_url(url, dest)
        expect(path).not_to be_nil
      end

      it 'returns path' do
        path = described_class.download_from_url(url, dest)
        expect(File).to exist(path)
      end
    end

    context 'when file exists' do
      it 'does not download file' do
        path = described_class.download_from_url(url, dest)
        mtime1 = File.mtime(path)
        described_class.download_from_url(url, dest)
        mtime2 = File.mtime(path)
        expect(mtime1).to eq(mtime2)
      end

      it 'returns nil' do
        described_class.download_from_url(url, dest)
        path = described_class.download_from_url(url, dest)
        expect(path).to be_nil
      end
    end
  end

  describe '.md5' do
    file_a = %w[spec/fixtures/test_files/1byte.bin spec/fixtures/test_files/1byte_2.bin]
    file_b = %w[spec/fixtures/test_files/16bytes.bin spec/fixtures/test_files/16bytes_2.bin]
    files = [file_a, file_b]

    context 'when files are identical' do
      files.each do |set|
        it "uses io (#{File.size(set[0])} bytes)" do
          expect(described_class.md5(io: File.open(set[0]))).to eq(described_class.md5(io: File.open(set[1])))
        end

        it "uses filename (#{File.size(set[0])} bytes)" do
          expect(described_class.md5(filename: set[0])).to eq(described_class.md5(filename: set[1]))
        end
      end
    end

    context 'when two files are different' do
      others = files.dup

      files.each do |set|
        f = set[0]
        others.delete(set)

        others.each do |other_set|
          o = other_set[0]

          it "uses io (#{File.size(f)} bytes <=> #{File.size(o)} bytes)" do
            expect(described_class.md5(io: File.open(f))).not_to eq(described_class.md5(io: File.open(o)))
          end

          it "uses filename (#{File.size(f)} bytes <=> #{File.size(o)} bytes)" do
            expect(described_class.md5(filename: f)).not_to eq(described_class.md5(filename: o))
          end
        end
      end
    end
  end
end
