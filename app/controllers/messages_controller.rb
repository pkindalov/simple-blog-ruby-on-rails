class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:receiver_id]
      @receiver = User.find(params[:receiver_id])
      @messages = Message.between(current_user, @receiver)
      @messages = @messages.where('content LIKE ?', "%#{params[:query]}%") if params[:query].present?
      @messages = @messages.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
      @messages.where(receiver: current_user).update_all(read: true)
      @message = current_user.sent_messages.build(receiver: @receiver)
    end

    @users = current_user.following & current_user.followers
  end




  def create
    @receiver = User.find(params[:message][:receiver_id])
    @message = current_user.sent_messages.build(message_params.merge(receiver: @receiver))

    if @message.save
      redirect_to messages_path(receiver_id: @receiver.id), notice: 'Message sent successfully.'
    else
      redirect_to messages_path(receiver_id: @receiver.id), alert: 'Failed to send message.'
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def conversation_with(user)
    Message.where(sender: current_user, receiver: user)
           .or(Message.where(sender: user, receiver: current_user))
           .order(created_at: :asc)
  end
end
