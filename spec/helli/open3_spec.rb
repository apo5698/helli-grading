# frozen_string_literal: true

describe Helli::Open3 do
  shell = 'sh'
  path = 'spec/fixtures/open3'

  stdout = 0
  stderr = 1
  status = 2

  describe '#capture3t' do
    context 'when writing to a single stream' do
      it 'reads stdout' do
        p = described_class.capture3t(shell, File.join(path, 'stdout.sh'))
        expect(p[stdout]).to eq('stdout')
      end

      it 'reads stderr' do
        p = described_class.capture3t(shell, File.join(path, 'stderr.sh'))
        expect(p[stderr]).to eq('stderr')
      end

      it 'reads open3 status' do
        p = described_class.capture3t(shell, File.join(path, 'return1.sh'))
        expect(p[status].exitstatus).to eq(1)
      end

      it 'writes stdin' do
        data = 'helli'
        p = described_class.capture3t(shell, File.join(path, 'stdin.sh'), stdin_data: data)
        expect(p[stdout]).to eq(data)
      end
    end

    context 'when writing to multiple streams' do
      p = described_class.capture3t(shell, File.join(path, 'stdout_stderr.sh'))

      it 'reads stdout' do
        expect(p[stdout]).to eq('stdout')
      end

      it 'reads stderr' do
        expect(p[stderr]).to eq('stderr')
      end
    end

    context 'when running program that never exits' do
      p = described_class.capture3t(shell, File.join(path, 'infinite_loop.sh'), timeout: 1)

      it 'reads stdout' do
        expect(p[stdout]).to eq('stdout')
      end

      it 'reads stderr' do
        expect(p[stderr]).to eq('stderr')
      end

      it 'returns nil' do
        expect(p[status].exitstatus).to be_nil
      end
    end
  end
end
