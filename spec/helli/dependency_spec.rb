# frozen_string_literal: true

describe Helli::Dependency, ignore_clean: true do
  let(:root) { described_class::ROOT }

  let(:direct) { create(:dependency) }
  let(:git) { create(:dependency, type: 'git') }

  describe '.load' do
    it 'creates records in database' do
      expect(described_class.pluck(:name)).to eq(described_class.load.keys)
    end
  end

  describe '.download_all' do
    it('has all dependencies downloaded before tests') { expect(File).to exist(root) }

    it('removes all downloaded dependencies') { FileUtils.remove_entry_secure(root) }

    described_class.all.each do |d|
      it("removes #{d.name}") { expect(File).not_to exist("#{root}/#{d.type}/#{d.name}") }
    end

    it('downloads all dependencies') { described_class.download_all }

    described_class.all.each do |d|
      it("downloads #{d.name}") { expect(File).to exist("#{root}/#{d.type}/#{d.name}") }
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

    # reset dependencies
    described_class.setup
  end

  describe '#name' do
    it('is invalid if name exists') { expect(build(:dependency, name: git.name)).to be_invalid }
  end

  describe '#path' do
    it 'concatenates local path (git)' do
      expect(git.path).to eq(Rails.root.join(root, git.type, git.name, git.executable).to_s)
    end

    it 'concatenates local path (direct)' do
      expect(direct.path).to eq(Rails.root.join(root, direct.type, direct.name, direct.executable).to_s)
    end
  end

  describe '#download' do
    it('ensures all local files removed') { FileUtils.remove_entry_secure(root) }

    described_class.all.each do |d|
      it "downloads #{d.name}" do
        d.download
        expect(File).to exist("#{root}/#{d.type}/#{d.name}")
      end
    end
  end
end
