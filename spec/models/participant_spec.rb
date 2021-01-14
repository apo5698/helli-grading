# frozen_string_literal: true

describe Participant do
  let(:course) { create(:course) }
  let(:assignment) { create(:exercise, course_id: course.id) }
  let(:participant) { create(:participant, assignment_id: assignment.id) }

  describe 'validation' do
    it 'is valid' do
      expect(participant).to be_valid
    end

    %i[identifier full_name email_address maximum_grade].each do |attr|
      it "validates presence of #{attr}" do
        participant.send("#{attr}=", nil)
        expect(participant).to be_invalid
      end
    end

    it 'cannot change grade if grade_can_be_changed is true' do
      participant.grade_can_be_changed = false
      participant.grade = 10
      expect(participant).to be_valid
    end
  end
end
