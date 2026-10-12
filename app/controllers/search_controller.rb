class SearchController < ApplicationController
  def index
    @query = params[:q].to_s
    @results = SearchService.new(user: current_user, query: @query).call
  end
end
