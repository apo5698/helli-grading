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

  describe '.path' do
    it { expect(described_class.path(git.name)).to eq(Rails.root.join(git.path).to_s) }
    it { expect(described_class.path(direct.name)).to eq(Rails.root.join(direct.path).to_s) }
  end

  describe '.destroy' do
    random = described_class.first

    it('is downloaded locally') { expect(File).to exist(random.path) }

    it 'removes local files' do
      random.destroy
      expect(File).not_to exist(random.path)
      load_dependencies
    end
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

  end
end
