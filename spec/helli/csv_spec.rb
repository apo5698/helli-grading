# frozen_string_literal: true

describe Helli::CSV do
  moodle_original = Helli::Random::CSV.new(:moodle).data
  moodle_header = described_class.header(:moodle)
  zybooks_original = Helli::Random::CSV.new(:zybooks).data
  zybooks_header = described_class.header(:zybooks)

  describe '.parse' do
    context 'Moodle' do
      moodle_parsed = described_class.parse(moodle_original, :moodle)

      it('has the same length') { expect(moodle_original.count).to eq(moodle_parsed.count) }

      context 'parses values correctly' do
        moodle_original.length.times do |i|
          moodle_header.each do |k, v|
            expected = moodle_original[i][v]
            actual = moodle_parsed[i][k]
            actual = case k
                     when :identifier
                       "Participant #{actual}"
                     when :grade_can_be_changed
                       actual == true ? 'Yes' : 'No'
                     when :last_modified_grade, :last_modified_submission
                       actual&.strftime(Helli::CSV::Adapter::MoodleGradingWorksheet::DATETIME_FORMAT) || '-'
                     else
                       actual
                     end

            it("[#{i}]#{moodle_header[k]}") { expect(actual).to eq(expected) }
          end
        end
      end
    end

    context 'zyBooks' do
      zybooks_parsed = described_class.parse(zybooks_original, :zybooks)

      it('has the same length') { expect(zybooks_original.count).to eq(zybooks_parsed.count) }

      context 'parses values correctly' do
        zybooks_original.length.times do |i|
          zybooks_header.each do |k, v|
            expected = zybooks_original[i][v]
            actual = zybooks_parsed[i][k]

            it("[#{i}]#{zybooks_header[k]}") { expect(actual).to eq(expected) }
          end
        end
      end
    end
  end
end
