# frozen_string_literal: true

describe Helli::CSV do
  describe described_class::Parser do
    moodle_original = CSVGenerator.moodle
    moodle_header = Helli::CSV::Adapter::MoodleGradingWorksheet::HEADER
    zybooks_original = CSVGenerator.zybooks
    zybooks_header = Helli::CSV::Adapter::ZybooksActivityReport::HEADER

    describe '.parse' do
      describe 'MoodleGradingWorksheet' do
        moodle_parsed = described_class.parse(moodle_original, Helli::CSV::Adapter::MoodleGradingWorksheet)

        it('has the same length') { expect(moodle_original.count).to eq(moodle_parsed.count) }

        describe 'parses values correctly' do
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

      describe 'zybooksActivityReport' do
        zybooks_parsed = described_class.parse(zybooks_original, Helli::CSV::Adapter::ZybooksActivityReport)

        it('has the same length') { expect(zybooks_original.count).to eq(zybooks_parsed.count) }

        describe 'parses values correctly' do
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

    describe '.header_valid?' do
      describe 'MoodleGradingWorksheet' do
        it 'has valid header' do
          expect(described_class).to be_header_valid(moodle_original.first&.keys, moodle_header.values)
        end
      end

      describe 'zybooksActivityReport' do
        it 'has valid header' do
          expect(described_class).to be_header_valid(zybooks_original.first&.keys, zybooks_header.values)
        end
      end
    end
  end
end
