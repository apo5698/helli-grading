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
    context 'when adding a program' do
      it 'adds a new program' do
        expect { exercise.add_program(filename) }.not_to raise_error
      end

      it 'cannot add an existing program' do
        expect do
          exercise.add_program(filename)
          exercise.add_program(filename)
        end.to raise_error(ArgumentError)
      end
    end

    context 'when deleting a program' do
      it 'deletes a existing program' do
        expect do
          exercise.add_program(filename)
          exercise.delete_program(filename)
        end.not_to raise_error
      end

      it 'cannot delete an non-existent program' do
        expect { exercise.delete_program(filename) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.grades_scale' do
    it 'has default values' do
      expect(exercise.grades_scale).to eq(Helli::Config::Scale.exercise)
      expect(project.grades_scale).to eq(Helli::Config::Scale.project)
    end

    context 'when scale is valid' do
      it 'has all 3 values' do
        scale = { program: 50, zybooks: 25, other: 25 }
        expect { exercise.grades_scale = scale }.not_to raise_error
        expect(exercise.grades_scale).to eq(scale)
      end

      it 'has 2 values but not other' do
        expect { exercise.grades_scale = { program: 50, zybooks: 50 } }.not_to raise_error
        expect(exercise.grades_scale).to eq({ program: 50, zybooks: 50, other: 0 })
      end

      it 'only has program value' do
        expect { exercise.grades_scale = { program: 75 } }.not_to raise_error
        expect(exercise.grades_scale).to eq({ program: 75, zybooks: 25, other: 0 })
      end

      it 'only has zybooks value' do
        expect { exercise.grades_scale = { zybooks: 75 } }.not_to raise_error
        expect(exercise.grades_scale).to eq({ program: 25, zybooks: 75, other: 0 })
      end
    end

    context 'when scale is invalid' do
      it 'has program value of 0' do
        scale = { program: 0 }
        expect { exercise.grades_scale = scale }.to raise_error(ArgumentError)
      end

      it 'has zybooks value of 0' do
        scale = { zybooks: 0 }
        expect { exercise.grades_scale = scale }.to raise_error(ArgumentError)
      end

      it 'has other value of 0' do
        scale = { other: 0 }
        expect { exercise.grades_scale = scale }.to raise_error(ArgumentError)
      end

      it 'has invalid sum with 3 values' do
        scale = { program: 100, zybooks: 100, other: 100 }
        expect { exercise.grades_scale = scale }.to raise_error(ArgumentError)
      end

      it 'has invalid sum with 2 values' do
        scale = { program: 50, zybooks: 75 }
        expect { exercise.grades_scale = scale }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.zybooks_scale' do
    it 'has default values' do
      expect(exercise.zybooks_scale).to eq(Helli::Config::Scale.zybooks)
    end

    context 'when scale is valid' do
      it 'has at least 1 level' do
        scale = { 90 => 90 }
        expect { exercise.zybooks_scale = scale }.not_to raise_error
        expect(exercise.zybooks_scale).to eq(scale)
      end

      it 'has multiple levels' do
        scale = { 90 => 100, 80 => 80, 60 => 60 }
        expect { exercise.zybooks_scale = scale }.not_to raise_error
        expect(exercise.zybooks_scale).to eq(scale)
      end
    end

    context 'when scale is invalid' do
      it 'is empty' do
        scale = {}
        expect { exercise.zybooks_scale = scale }.to raise_error(ArgumentError)
      end

      it 'is not sorted correctly' do
        scale = { 90 => 50, 80 => 60, 70 => 100 }
        expect { exercise.zybooks_scale = scale }.to raise_error(ArgumentError)
      end
    end
  end
end
