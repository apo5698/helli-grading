# frozen_string_literal: true

describe Config do
  classes = [String, Array, Hash]

  describe '.get' do
    classes.each do |klass|
      it "returns #{klass}" do
        expect(described_class.get("test.#{klass}")).to be_a(klass)
      end
    end
  end
end
