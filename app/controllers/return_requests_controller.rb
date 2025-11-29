class ReturnRequestsController < ApplicationController

  before_action :set_return_request, only: [:show]

  def index
    @return_requests = ReturnRequest.order(created_at: :desc)

    respond_to do |format|
      format.json { render json: @return_requests }
      format.html { render :index }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @return_request }
      format.html { render :show }
    end
  end

  def new
    @return_request = ReturnRequest.new
  end

  def create
    @return_request = ReturnRequest.new(parsed_return_request_params)

    if @return_request.save
      ReturnRequestProcessorJob.perform_later(@return_request.id)
      respond_to do |format|
        format.json { render_success(success_payload_for(@return_request), status: :accepted) }
        format.html { redirect_to @return_request, notice: "Return request created. Processing has been queued and may take a moment." }
      end
    else
      respond_with_request_errors(@return_request)
    end
  end

  private

  def set_return_request
    @return_request = ReturnRequest.find(params[:id])
  end

  def return_request_params
    params.require(:return_request).permit(
      :order_id,
      :customer_id,
      :order_value_cents,
      :currency,
      :reason,
      :description,
      metadata: {}
    )
  end
end

