describe User do

  let(:user) { FactoryGirl.create(:user, first_name: "George", last_name: "Jetson") }

  context 'valid attributes' do
    it 'should be valid' do
      expect(user).to be_valid
    end
  end

  context 'non-valid attributes' do
    it 'should not be valid' do
      user.email_address = nil
      expect(user).to_not be_valid
    end
  end

  describe '#full_name' do
    it 'return first name and last name' do
      expect(user.full_name).to eq 'George Jetson'
    end

    it "returns the user's email address if no first name and last name" do
      user.first_name = nil
      user.last_name = nil
      user.email_address = 'george.jetson@spacelysprockets.com'

      expect(user.full_name).to eq 'george.jetson@spacelysprockets.com'
    end
  end

  describe '.for_email' do
    it "downcases and strips the email" do
      user = User.for_email('   miXedCaSe@some-doT-gov.gov')
      expect(user.email_address).to eq('mixedcase@some-dot-gov.gov')
    end
  end
end
