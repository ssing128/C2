describe 'Testing User Ownership of Comments' do

# Create Two carts with the same user to prove we can detect user who created comment.
  before do
    approval_group = ApprovalGroup.create!(name: "A Testworthy Approval Group")

    cart = Cart.new(
                    name: 'My Wonderfully Awesome Communicart',
                    status: 'pending',
                    external_id: '10203040'
                    )
    user = User.create!(email_address: 'test-requester@some-dot-gov.gov')

    UserRole.create!(user_id: user.id, approval_group_id: approval_group.id, role: 'requester')
    cart.approval_group = approval_group

    cart.approvals << Approval.create!(user_id: user.id, role: 'requester')

    users = []


    (0..3).each do |num|
      email = "approver#{num}@some-dot-gov.gov"

      users[num] = FactoryGirl.create(:user, email_address: email)
      approval_group.user_roles << UserRole.create!(user_id: users[num].id, approval_group_id: approval_group.id, role: 'approver')
      cart.approvals << Approval.create!(user_id: users[num].id, role: 'approver')
    end

    cart.save

    cart2 = Cart.new(
                    name: 'My Fabulous Second Communicart',
                    status: 'pending',
                    external_id: '10203040'
                    )

    cart2.approval_group = approval_group

    cart2.approvals << Approval.create!(user_id: user.id, role: 'requester')

    (1..3).each do |num|
      approval_group.user_roles << UserRole.create!(user_id: users[num].id, approval_group_id: approval_group.id, role: 'approver')
      cart2.approvals << Approval.create!(user_id: users[num].id, role: 'approver')
    end

    cart2.save
  end


  it 'updates the comments on a cart as expected' do
    expect(Cart.count).to eq(2)
    expect(User.count).to eq(5) # 5 = 4 approvers + 1 requester
    cart = Cart.first
    expect(cart.pending?).to eq true
    expect(cart.approvals.approved.count).to eq 0
    expect(cart.comments.count).to eq 0
    expect(deliveries.count).to eq 0

    cart2 = Cart.last

    # Cart2 has a comment that has the correct user.


    # basically add an approval comment as currently done --- CONSIDER MAKING THIS A FUNCTION
     user = cart.approvers.where(email_address: "approver1@some-dot-gov.gov").first
     user2 = cart.approvers.where(email_address: "approver2@some-dot-gov.gov").first
     new_comment = Comment.new(user_id: user.id,comment_text: "spud")
     snd_comment = Comment.new(user_id: user2.id,comment_text: "second")
     cart.proposal.comments << new_comment
     cart.proposal.comments << snd_comment

    # We can add approval comments to both carts and distinguish them.
    expect(cart.comments[0].user_id).not_to eq cart.comments[1].user_id

    expect(cart.comments[0].user_id).to eq user.id
    expect(cart.comments[1].user_id).to eq user2.id

    # We want the code int he cart model to only put comments for the correct cart into the CSV.

    # First, we'll build the second cart....

     cart2.comments << Comment.new(user_id: user.id,comment_text: "Lincoln")
     cart2.comments << Comment.new(user_id: user2.id,comment_text: "Washington")

    # Invoke Create_comments_csv and check...

    csv = Exporter::Comments.new(cart2).to_csv

    expect(csv.lines.count).to eq 3

  end
end
