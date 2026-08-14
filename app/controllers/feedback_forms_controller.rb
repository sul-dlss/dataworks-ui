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
        redirect_to return_url
      end
      format.turbo_stream
    end
  end

  private

  # params[:url] is the (user-controlled) page the feedback was submitted from.
  # url_from returns it only when it's safe to redirect to (a same-host or
  # path-relative URL); otherwise fall back to the home page.
  def return_url
    url_from(params[:url]) || root_path
  end

  def valid?
    errors = []
    collect_errors(errors)
    assign_error_flash(errors)
    flash.now[:error].nil?
  end

  def collect_errors(errors)
    errors << t('feedback_form.errors.recaptcha') unless verify_recaptcha(action: 'feedback', minimum_score: 0.5)
    errors << t('feedback_form.errors.email_required') if params[:to].blank?
    errors << t('feedback_form.errors.message_required') if params[:message].blank?
  end

  def assign_error_flash(errors)
    flash.now[:error] = errors.join('<br/>') unless errors.empty?
  end
end
