class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [ :show, :update, :cancel ]

  def index
    page = params[:page].to_i
    page = 1 if page <= 0

    per_page = 2
    max_pages = 4

    if page > max_pages
      return render json: { error: "Page limit exceeded. Maximum allowed page is #{max_pages}" }, status: :unprocessable_entity
    end

    appointments = Appointment
                    .order(start_time: :asc)
                    .limit(per_page)
                    .offset((page - 1) * per_page)

    render json: {
      data: appointments,
      meta: {
        page: page,
        per_page: per_page,
        total: Appointment.count,
        max_pages: max_pages
      }
    }
  end

  def show
    render json: { data: @appointment }, status: :ok
  end

  def create
    appointment = Appointment.new(appointment_params)

    if appointment.save
      render json: { data: appointment }, status: :created
    else
      render_validation_error(appointment)
    end
  end

  def update
    if @appointment.update(appointment_params)
      render json: { data: @appointment }, status: :ok
    else
      render_validation_error(@appointment)
    end
  end

  def cancel
    return render json: { error: "Already cancelled" }, status: :unprocessable_entity if @appointment.cancelled?
    @appointment.cancelled!
    render json: { data: @appointment }, status: :ok
  end

  private

  def set_appointment
    @appointment = Appointment.find_by(id: params[:id])
    render_not_found unless @appointment
  end

  def appointment_params
    params.require(:appointment).permit(:start_time, :end_time, :status)
  end

  def apply_filters(scope)
    if params[:start_date].present? && params[:end_date].present?
      scope = scope.where("start_time >= ? AND start_time <= ?", params[:start_date], params[:end_date])
    end
    scope
  end

  def apply_pagination(scope)
    @page = (params[:page].to_i > 0 ? params[:page].to_i : 1)
    @per_page = (params[:per_page].to_i > 0 ? params[:per_page].to_i : 10)

    scope.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def pagination_meta(scope)
    {
      page: @page || 1,
      per_page: @per_page || 2,
      total: scope.count
    }
  end

  def render_not_found
    render json: {
      error: {
        code: "not_found",
        message: "Appointment not found"
      }
    }, status: :not_found
  end

  def render_validation_error(resource)
    render json: {
      error: {
        code: "validation_failed",
        message: resource.errors.full_messages.join(", ")
      }
    }, status: :unprocessable_entity
  end

  def render_bad_request(message)
    render json: {
      error: {
        code: "bad_request",
        message: message
      }
    }, status: :bad_request
  end
end
