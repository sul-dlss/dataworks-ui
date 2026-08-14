# frozen_string_literal: true

class FeedbackMailerParser
  attr_reader :params, :ip

  def initialize(params, ip)
    @params = params
    @ip = ip
  end

  def name
    safe(params.fetch(:name, 'No name given'))
  end

  def email
    safe(params.fetch(:to, 'No email given'))
  end

  def message
    safe(params[:message].to_s)
  end

  def url
    safe(params[:url])
  end

  def user_agent
    safe(params[:user_agent])
  end

  def viewport
    safe(params[:viewport])
  end

  def last_search
    safe(params[:last_search])
  end

  private

  # These fields are raw, user-controlled request values (form params and
  # headers) rendered into the feedback email. They can arrive as ASCII-8BIT
  # (BINARY) strings, which raise Encoding::CompatibilityError when appended to
  # the UTF-8 email template buffer, so coerce any string to valid UTF-8.
  def safe(value)
    return value unless value.is_a?(String)

    value.dup.force_encoding('UTF-8').scrub
  end
end
