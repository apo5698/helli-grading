describe 'Program' do
  let(:course) { create(:course) }
  let(:assignment) { create(:exercise, course_id: course.id) }

  let!(:source) { create(:java_source, assignment_id: assignment.id) }
  let!(:test1) { create(:java_test, assignment_id: assignment.id, parent_program_id: source.id) }
  let!(:test2) { create(:java_test, name: 'H.java', assignment_id: assignment.id, parent_program_id: source.id) }

  describe '#name' do
    it 'requires a name' do
      source.name = nil
      expect(source).to be_invalid
    end
  end

  describe '#extension' do
    it 'infers extension' do
      expect(source.extension).to eq(File.extname(source.name))
    end
  end

  describe 'associations' do
    it 'has many child programs' do
      expect(source.child_programs).to include(test1, test2)
    end

    it 'belongs to one parent program' do
      expect(test1.parent_program).to eq(source)
    end

    it 'destroys one child program' do
      test1.destroy
      expect(source.child_programs).to include(test2)
    end

    it 'destroys all child programs' do
      test1.destroy
      test2.destroy
      expect(source.child_programs).to be_empty
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'destroys parent program' do
      source.destroy
      expect(test1.parent_program).to be_nil
      expect(test2.parent_program).to be_nil
    end
  end
end
