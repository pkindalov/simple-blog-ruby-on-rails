# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_receiver, only: %i[index create]
  before_action :set_message, only: %i[edit update destroy]

  def index
    @users = current_user.mutual_following

    # Създаване на хеш с броя на непрочетените съобщения за всеки изпращач
    @unread_counts = Message.where(receiver: current_user, read: false)
                            .group(:sender_id)
                            .count

    @receiver = User.find_by(id: params[:receiver_id])
    @messages = @receiver ? Message.between(current_user, @receiver).order(created_at: :desc).paginate(page: params[:page], per_page: 10) : []
    @messages = @messages.where('content LIKE ?', "%#{params[:query]}%") if params[:query].present?
    @messages.where(receiver: current_user).update_all(read: true) if @receiver

    @message = current_user.sent_messages.build(receiver: @receiver)
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    if @message.save
      redirect_to messages_path(receiver_id: @message.receiver_id), notice: 'Message sent!'
    else
      redirect_to messages_path(receiver_id: @message.receiver_id), alert: 'Message failed to send.'
    end
  end

  def edit
    @receiver = @message.receiver
  end

  def update
    if @message.update(message_params)
      redirect_to messages_path(receiver_id: @message.receiver_id), notice: 'Message updated!'
    else
      render :edit
    end
  end

  def destroy
    @message.destroy
    redirect_to messages_path(receiver_id: @message.receiver_id), notice: 'Message deleted.'
  end

  def destroy_conversation
    if params[:receiver_id]
      receiver = User.find(params[:receiver_id])
      messages = Message.between(current_user, receiver)
      messages.destroy_all
      redirect_to messages_path, notice: 'Conversation deleted.'
    else
      redirect_to messages_path, alert: 'No conversation selected.'
    end
  end

  private

  def set_receiver
    @receiver = User.find_by(id: params[:receiver_id])
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, :receiver_id)
  end
end
