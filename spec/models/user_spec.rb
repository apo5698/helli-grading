# frozen_string_literal: true

describe User do
  let!(:admin) { create(:admin) }

  describe '#name' do
    it 'must be present' do
      admin.name = nil
      expect(admin).to be_invalid
    end
  end

  describe '#username' do
    it 'must be present' do
      admin.username = nil
      expect(admin).to be_invalid
    end
  end

  describe '#email' do
    it 'must be present' do
      admin.email = nil
      expect(admin).to be_invalid
    end

    it 'must match email format' do
      admin.email = 'helli.app'
      expect(admin).to be_invalid
    end
  end

  describe '#password' do
    it 'must be present' do
      admin.password = nil
      expect(admin).to be_invalid
    end

    it 'must contain at least 6 characters' do
      admin.password = '123'
      expect(admin).to be_invalid
    end

    it 'must match password and password confirmation' do
      admin.password = '123456'
      admin.password_confirmation = '12345678'
      expect(admin).to be_invalid
    end
  end

  describe '#role' do
    let(:user) { create(:user) }

    it 'sets default role to student' do
      expect(user.role).to eq('student')
    end

    it 'invalid if with an undefined role' do
      suppress ArgumentError do
        invalid_role = 'whoami'
        user.role = invalid_role
        raise "role '#{invalid_role}' should be invalid"
      end
    end
  end

  describe '#to_s' do
    it 'returns name' do
      expect(admin.to_s).to eq(admin.name)
    end
  end

  describe 'after sign up' do
    # rubocop:disable Lint/MissingCopEnableDirective
    # rubocop:disable RSpec/LetSetup
    let!(:unconfirmed_user) { create(:unconfirmed_user) }

    it 'sends confirmation email' do
      expect(Devise.mailer.deliveries.size).to eq(1)
    end
  end
end
