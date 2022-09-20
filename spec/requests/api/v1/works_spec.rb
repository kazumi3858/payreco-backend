# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Works', type: :request do
  let(:current_user) { create(:user) }

  before do
    authorization_stub
  end

  describe 'GET /work' do
    before do
      create_list(:work, 10, user_id: current_user.id)
      get '/api/v1/works'
    end

    it 'returns expected status' do
      expect(response).to have_http_status(:ok)
      assert_response_schema_confirm
    end

    it 'has expected responses' do
      expect(JSON.parse(response.body).length).to eq(10)
    end
  end

  describe 'POST /api/v1/works' do
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:company) { create(:company) }

    context 'when create' do
      let(:params) { attributes_for(:work, user_id: current_user.id, company_id: company.id).to_json }

      it 'returns expected status' do
        post '/api/v1/works', params: params, headers: headers
        expect(response).to have_http_status(:created)
        assert_request_schema_confirm
      end
    end
  end

  describe 'PATCH /api/v1/works/:id' do
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:company) { create(:company) }

    context 'when update' do
      let(:params) { attributes_for(:work, user_id: current_user.id, company_id: company.id).to_json }

      it 'returns expected status' do
        work = create(:work, user_id: current_user.id)
        patch "/api/v1/works/#{work.id}", params: params, headers: headers
        expect(response).to have_http_status(:ok)
        assert_request_schema_confirm
      end
    end
  end

  describe 'DELETE /api/v1/works/:id' do
    let(:headers) { { 'Content-Type' => 'application/json' } }

    context 'when delete' do
      it 'returns expected status' do
        work = create(:work, user_id: current_user.id)
        delete "/api/v1/works/#{work.id}", headers: headers
        expect(response).to have_http_status(:no_content)
        assert_request_schema_confirm
      end
    end
  end
end