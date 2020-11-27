# frozen_string_literal: true

describe Helli::Dependency, ignore_clean: true do
  let(:config) { ENV['DEPENDENCIES_FILE'] }
  let(:config_empty) { 'spec/fixtures/dependency/empty.yml' }
  let(:root) { described_class.root }

  let(:direct) { create(:dependency, source_type: 'direct', executable: '') }
  let(:git) { create(:dependency, source_type: 'git', source: '') }

  describe '.root' do
    it('sets up the root path') { expect(root).not_to be_nil }
  end

  describe '.load' do
    it 'sets the root path from file' do
      expect(root).to eq(YAML.load_file(config)['root'])
    end

    it 'creates records in database' do
      expect(described_class.pluck(:name)).to eq(described_class.load(config).keys)
    end

    it 'cannot load empty file' do
      expect { described_class.load(config_empty) }.to raise_error(Helli::EmptyFileError)
    end
  end

  describe '.download_all' do
    it('has all dependencies downloaded before tests') { expect(File).to exist(root) }

    it('removes all downloaded dependencies') { FileUtils.remove_entry_secure(root) }

    described_class.all.each do |d|
      it("removes #{d.name}") { expect(File).not_to exist("#{root}/#{d.source_type}/#{d.name}") }
    end

    it('downloads all dependencies') { described_class.download_all }

    described_class.all.each do |d|
      it("downloads #{d.name}") { expect(File).to exist("#{root}/#{d.source_type}/#{d.name}") }
    end
  end

  describe '#destroy' do
    described_class.all.each do |d|
      it("#{d.name} is downloaded locally") { expect(File).to exist(d.path) }

      it "removes #{d.name} local files" do
        d.destroy
        expect(File).not_to exist(d.path)
      end
    end

    load_dependencies
  end

  describe '#name' do
    it('is invalid if name exists') { expect(build(:dependency, name: git.name)).to be_invalid }
  end

  describe '#path' do
    it 'concatenates local path (git)' do
      expect(git.path).to eq("#{root}/#{git.source_type}/#{git.name}/#{git.executable}")
    end

    it 'concatenates local path (direct)' do
      expect(direct.path).to eq("#{root}/#{direct.source_type}/#{direct.name}/#{direct.executable}")
    end
  end

  describe '#download' do
    it('ensures all local files removed') { FileUtils.remove_entry_secure(root) }

    described_class.all.each do |d|
      it "downloads #{d.name}" do
        d.download
        expect(File).to exist("#{root}/#{d.source_type}/#{d.name}")
      end
    end
  end
end
