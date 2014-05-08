class CommunicartsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_cart
    cart = Cart.initialize_cart_with_items(params)

    # Note: There surely should be a better way to fill this in since we just
    # create the object above, but I don't really know how to do that...
    cart = Cart.find_by(external_id: (params['cartNumber'].to_i))
    cart.decorate

    Comment.create(comment_text: params['initiationComment'].strip, cart_id: cart.id) unless params['initiationComment'].blank?

    approval_group_name = params['approvalGroup']

    sum = params['cartItems'].reduce(0) do |sum,value|
      sum + (value["qty"].gsub(/[^\d\.]/, '').to_f *  value["price"].gsub(/[^\d\.]/, '').to_f)
    end
    params['totalPrice'] = "%0.2f" % sum

    if !approval_group_name.blank?
      approval_group = ApprovalGroup.find_by(name: approval_group_name)

      approval_group.users.each do | user |
        Approval.create!(user_id: user.id, cart_id: cart.id)
        CommunicartMailer.cart_notification_email(user.email_address,params,cart).deliver
      end
    else
      CommunicartMailer.cart_notification_email(params["email"],params,cart).deliver
    end
    render json: { message: "This was a success"}, status: 200
  end

  def approval_reply_received
    cart = Cart.find_by(external_id: (params['cartNumber'].to_i))
    cart.decorate

    user = cart.approval_group.users.where(email_address: params['fromAddress']).first
    ApproverComment.create(comment_text: params['comment'].strip, approver_id: user.id) unless params['comment'].blank?
    Comment.create(comment_text: params['comment'].strip, cart_id: cart.id) unless params['comment'].blank?

    user = User.find_by(email_address: params['fromAddress'])
    approval = cart.approvals.where(user_id: user.id).first

    approval.update_attributes(status: approve_or_reject_status)
    cart.update_approval_status

    cart_report = EmailStatusReport.new(cart)
    CommunicartMailer.approval_reply_received_email(params, cart_report).deliver
    render json: { message: "approval_reply_received"}, status: 200
  end

  def approve_or_reject_status
    #TODO: Refactor duplication with ComunicartMailer#approval_reply_received_email
    return 'approved' if params["approve"] == "APPROVE"
    return 'rejected' if params["disapprove"] == "REJECT"
  end
end
