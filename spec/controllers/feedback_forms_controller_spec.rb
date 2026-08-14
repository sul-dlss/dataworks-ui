# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackFormsController do
  before do
    allow(controller).to receive(:verify_recaptcha).and_return(true)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'sends an email' do
        expect do
          post :create, params: { url: 'http://test.host/', to: 'user@example.com', message: 'Hello' }
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it 'sets a success flash message' do
        post :create, params: { url: 'http://test.host/', to: 'user@example.com', message: 'Hello' }
        expect(flash[:success]).to be_present
      end
    end

    context 'when message is missing' do
      it 'does not send an email' do
        expect do
          post :create, params: { url: 'http://test.host/', to: 'user@example.com', message: '' }
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end

      it 'sets an error flash message' do
        post :create, params: { url: 'http://test.host/', to: 'user@example.com', message: '' }
        expect(flash[:error]).to include('message')
      end
    end

    context 'when email is missing' do
      it 'does not send an email' do
        expect do
          post :create, params: { url: 'http://test.host/', to: '', message: 'Hello' }
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end

      it 'sets an error flash message' do
        post :create, params: { url: 'http://test.host/', to: '', message: 'Hello' }
        expect(flash[:error]).to include('email')
      end
    end

    context 'when reCAPTCHA fails' do
      before do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
      end

      it 'does not send an email' do
        expect do
          post :create, params: { url: 'http://test.host/', to: 'user@example.com', message: 'Hello' }
        end.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    describe 'redirect after submission' do
      let(:base_params) { { to: 'user@example.com', message: 'Hello' } }

      it 'redirects back to a safe same-host url' do
        post :create, params: base_params.merge(url: 'http://test.host/catalog/1')
        expect(response).to redirect_to('http://test.host/catalog/1')
      end

      it 'falls back to the home page when the url is missing' do
        post :create, params: base_params
        expect(response).to redirect_to(root_path)
      end

      it 'falls back to the home page for an off-host url' do
        post :create, params: base_params.merge(url: 'https://bad.example.com/')
        expect(response).to redirect_to(root_path)
      end

      it 'falls back to the home page for a path-relative or malformed url' do
        post :create, params: base_params.merge(url: '-1 OR 5*5=26 -- ')
        expect(response).to redirect_to(root_path)
      end

      it 'falls back to the home page when the url is an array' do
        post :create, params: base_params.merge(url: ['http://test.host/'])
        expect(response).to redirect_to(root_path)
      end

      it 'falls back to the home page when the url is a hash' do
        post :create, params: base_params.merge(url: { '$eq' => 'http://test.host/' })
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
