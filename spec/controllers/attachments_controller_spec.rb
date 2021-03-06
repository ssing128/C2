describe AttachmentsController do
  describe 'permission checking' do
    let (:proposal) { FactoryGirl.create(:proposal, :with_approvers,
                                         :with_observers, :with_cart) }
    let (:params) {{
      proposal_id: proposal.id, 
      attachment: { file: fixture_file_upload('icon-user.png', 'image/png') }
    }}
                     
    it "allows the requester to add an attachment" do
      login_as(proposal.requester)
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:error]).not_to be_present
      expect(response).to redirect_to(proposal)
      expect(proposal.attachments.count).to eq(1)
    end

    it "allows an approver to add an attachment" do
      login_as(proposal.approvers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
      expect(proposal.attachments.count).to eq(1)
    end

    it "allows an observer to add an attachment" do
      login_as(proposal.observers[0])
      post :create, params
      expect(flash[:success]).to be_present
      expect(flash[:alert]).not_to be_present
      expect(response).to redirect_to(proposal)
      expect(proposal.attachments.count).to eq(1)
    end

    it "does not allow others to add an attachment" do
      login_as(FactoryGirl.create(:user))
      post :create, params
      expect(flash[:success]).not_to be_present
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to(proposals_path)
      expect(proposal.attachments.count).to eq(0)
    end
  end

  describe 'error handling' do
    it "gives an error when a file was not selected" do
      proposal = FactoryGirl.create(:proposal)
      login_as(proposal.requester)
      post :create, { proposal_id: proposal.id }
      expect(flash[:success]).not_to be_present
      expect(flash[:error]).to be_present
      expect(response).to redirect_to(proposal_path(proposal))
      expect(proposal.attachments.count).to eq(0)
    end
  end
end
