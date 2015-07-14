class ContentsController < ApplicationController
  has_scope :page, default: 1
  has_scope :per, default: 10
  before_action :require_teacher, only: [:new, :create, :edit, :update]
  before_action :set_number_of_classes, only: [:new, :create, :edit, :update]
  before_action :require_current_school_calendar

  def index
    @contents = apply_scopes(Content.includes(:unity, :classroom, :discipline).ordered)

    authorize @contents
  end

  def new
    @content = resource
    @content.school_calendar = current_school_calendar

    authorize resource

    fetch_classrooms
  end

  def create
    resource.assign_attributes resource_params
    resource.school_calendar = current_school_calendar

    authorize resource

    if resource.save
      respond_with resource, location: contents_path
    else
      fetch_classrooms

      render :new
    end
  end

  def edit
    @content = resource

    authorize resource

    fetch_classrooms
  end

  def update
    resource.assign_attributes resource_params

    authorize resource

    if resource.save
      respond_with resource, location: contents_path
    else
      fetch_classrooms

      render :edit
    end
  end

  def destroy
    authorize resource

    resource.destroy

    respond_with resource, location: contents_path
  end

  def history
    @content = Content.find(params[:id])

    authorize @content

    respond_with @content
  end

  private

  def set_number_of_classes
    @number_of_classes = current_school_calendar.number_of_classes
  end

  def fetch_classrooms
    fetcher = UnitiesClassroomsDisciplinesByTeacher.new(current_teacher.id, @content.unity_id, @content.classroom_id)
    fetcher.fetch!
    @unities = fetcher.unities
    @classrooms = fetcher.classrooms
    @disciplines = fetcher.disciplines
  end

  def resource
    @content ||= case params[:action]
    when 'new', 'create'
      Content.new
    when 'edit', 'update', 'destroy'
      Content.find(params[:id])
    end.localized
  end

  def resource_params
    params.require(:content).permit(
      :unity_id, :classroom_id, :discipline_id, :school_calendar_id, :content_date, :class_number, :description
    )
  end

  def require_teacher
    unless current_teacher
      flash[:alert] = t('errors.contents.require_teacher')
      redirect_to contents_path
    end
  end
end