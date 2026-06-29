# frozen_string_literal: true

class FeedbackFormsController < ApplicationController
  def new; end

  def create
    return unless request.post?

    if valid?
      FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
      flash.now[:success] = t('feedback_form.success')
    end
    respond_to do |format|
      format.json do
        render json: flash
      end
      format.html do
        redirect_to params[:url]
      end
      format.turbo_stream
    end
  end

  private

  def valid?
    errors = []
    collect_errors(errors)
    assign_error_flash(errors)
    flash.now[:error].nil?
  end

  def collect_errors(errors)
    errors << t('feedback_form.errors.recaptcha') unless verify_recaptcha(action: 'feedback')
    errors << t('feedback_form.errors.email_required') if params[:to].blank?
    errors << t('feedback_form.errors.message_required') if params[:message].blank?
  end

  def assign_error_flash(errors)
    flash.now[:error] = errors.join('<br/>') unless errors.empty?
  end
end
