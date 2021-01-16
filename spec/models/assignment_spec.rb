describe Assignment do
  let(:course) { create(:course) }
  let(:exercise) { create(:exercise, course_id: course.id) }
  let(:project) { create(:project, course_id: course.id) }
  let(:filename) { "#{Faker::App.name.gsub(/\W/, '')}.java" }

  describe '.name' do
    it 'must present' do
      exercise.name = ''
      expect(exercise).to be_invalid
    end
  end

  describe '.category' do
    it 'must present' do
      exercise.category = nil
      expect(exercise).to be_invalid
    end
  end

  describe '.description' do
    it 'can be empty' do
      exercise.description = ''
      expect(exercise).to be_valid
    end
  end

  describe '.programs' do
    it 'adds a new program' do
      expect { exercise.programs.create(name: filename) }.not_to raise_error
    end

    it 'cannot add an existing program' do
      expect { 2.times { exercise.programs.create(name: filename) } }.to raise_error(Assignment::ProgramExists)
    end

    it 'deletes a program' do
      expect do
        exercise.programs.create(name: filename)
        exercise.programs.find_by(name: filename).destroy
      end.not_to raise_error
    end
  end
end
