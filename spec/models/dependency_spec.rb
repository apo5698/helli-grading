# frozen_string_literal: true

describe Dependency, ignore_clean: true do
  root = described_class::ROOT

  let(:direct) { create(:dependency) }
  let(:git) { create(:dependency, type: 'git') }

  describe '.load' do
    it 'has no dependency before testing' do
      described_class.destroy_all
      expect(described_class).not_to be_exists
    end

    it 'creates records in database' do
      names = described_class.load.keys
      expect(described_class.pluck(:name).sort).to eq(names.sort)
    end
  end

  describe '.download_all .delete_all_downloads' do
    it 'deletes all downloads' do
      described_class.delete_all_downloads
      described_class.find_each do |d|
        expect(Dir).not_to exist(d.dir)
      end
    end

    it 'downloads all dependencies' do
      described_class.download_all
      described_class.find_each do |d|
        expect(File).to exist(d.path)
      end
    end
  end

  describe '.public_dependencies' do
    it 'returns all public dependencies' do
      expect(described_class.public_dependencies).to eq(described_class.where(public: true))
    end
  end

  describe '#name' do
    it('is invalid if name exists') { expect(build(:dependency, name: git.name)).to be_invalid }
  end

  describe '#dir' do
    it 'returns directory where it is downloaded' do
      described_class.find_each do |d|
        expect(d.dir).to eq(Rails.root.join(root, d.type, d.name).to_s)
      end
    end
  end

  describe '#path' do
    it 'returns full path including directory and executable' do
      described_class.find_each do |d|
        expect(d.path).to eq(Rails.root.join(root, d.type, d.name, d.executable).to_s)
      end
    end
  end
end
