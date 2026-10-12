class DocumentsController < ApplicationController
  before_action :require_admin!, only: %i[new create]

  def index
    @documents = Document.visible_to(current_user).includes(:uploaded_by).order(created_at: :desc)
    @documents = @documents.where("LOWER(title) LIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.downcase)}%") if params[:q].present?
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params.merge(uploaded_by: current_user))
    if @document.save
      redirect_to documents_path, notice: "Document published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def document_params = params.require(:document).permit(:title, :category, :description, :visibility, :file)
end
