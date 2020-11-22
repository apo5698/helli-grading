describe HashSerializer do
  let(:model) { build(:exercise) }
  let(:hash) { { program: 50, zybooks: 50, other: 0 } }

  describe 'serialize' do
    it 'deserializes' do
      model.grades_scale = hash
      model.save
      expect(model.grades_scale).to eq(hash)
    end
  end
end