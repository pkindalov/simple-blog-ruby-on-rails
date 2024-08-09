class ReactionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @reactionable = find_reactionable
    return head :not_found unless @reactionable

    @reaction = @reactionable.reactions.find_or_initialize_by(user: current_user)

    if @reaction.persisted? && @reaction.reaction_type == reaction_params[:reaction_type]
      @reaction.destroy
      message = 'Reaction removed.'
    else
      @reaction.update(reaction_type: reaction_params[:reaction_type])
      message = 'Reaction added.'
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: message }
      format.json do
        render json: {
          success: true,
          reactions_html: render_to_string(
            partial: 'layouts/current_reactions',
            formats: [:html],
            locals: { message: @reactionable, reactions: reactions }
          )
        }
      end
    end
  rescue => e
    logger.error "Error creating reaction: #{e.message}"
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  private

  def find_reactionable
    if params[:message_id]
      Message.find_by(id: params[:message_id])
    end
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end

  def reactions
    { like: "👍", love: "❤️", laugh: "😂", wow: "😮", sad: "😢", angry: "😡" }
  end
end
