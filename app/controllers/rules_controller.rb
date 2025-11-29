class RulesController < ApplicationController
  before_action :set_rules, only: [:index]
  def index
    respond_to do |format|
      format.json { render json: @rules }
      format.html { render :index }
    end
  end

  private

  def set_rules
    @rules = Rule.by_priority
  end
end

