describe "Display status text" do
  let(:proposal) { 
    FactoryGirl.create(:proposal, :with_approvers, :with_cart) }
  before do
    login_as(proposal.requester)
  end

  it "displays approved status" do
    proposal.approvals.each{|approval| approval.approve!}
    visit proposals_path
    expect(page).to have_content('Approved')
  end

  it "displays rejected status" do
    proposal.approvals.first.reject!
    visit proposals_path
    expect(page).to have_content('Rejected')
  end

  it "displays outstanding approvers" do
    visit proposals_path
    expect(page).not_to have_content('Please review')
    expect(page).to have_content('Waiting for review from:')
    proposal.approvers.each{|approver|
      expect(page).to have_content(approver.full_name)}
  end

  it "excludes approved approvals" do
    proposal.approvals.first.approve!
    visit proposals_path
    expect(page).not_to have_content('Please review')
    expect(page).to have_content('Waiting for review from:')
    proposal.approvers[1..-1].each{|approver|
      expect(page).to have_content(approver.full_name)}
    expect(page).not_to have_content(proposal.approvers.first.full_name)
  end

  context "linear" do
    before do
      proposal.update_attribute(:flow, 'linear')
    end

    it "displays the first approver" do
      visit proposals_path
      expect(page).to have_content('Waiting for review from:')
      proposal.approvers[1..-1].each{|approver|
        expect(page).not_to have_content(approver.full_name)}
      expect(page).to have_content(proposal.approvers.first.full_name)
    end

    it "excludes approved approvals" do
      proposal.approvals.first.approve!
      visit proposals_path
      expect(page).to have_content('Waiting for review from:')
      expect(page).not_to have_content(proposal.approvers.first.full_name)
    end
  end
end

