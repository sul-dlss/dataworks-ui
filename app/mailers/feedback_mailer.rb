# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def submit_feedback(params, ip)
    @mailer_parser = FeedbackMailerParser.new(params, ip)

    mail(to: Settings.feedback_email,
         subject: t('feedback_form.email_subject'),
         from: Settings.feedback_email,
         reply_to: Settings.feedback_email)
  end
end
