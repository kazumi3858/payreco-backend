# frozen_string_literal: true

module Api
  module V1
    class OptionsRequestController < ApplicationController
      before_action :preflight

      def cors_preflight_check
        return unless request.method == 'OPTIONS'

        cors_set_access_control_headers
        render json: {}
        head :ok
      end

      protected

      def preflight
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] =
          'Origin, X-Requested-With, Content-Type, Authorization, Accept'
        response.headers['Access-Control-Max-Age'] = '1728000'
        response.headers['Access-Control-Allow-Credentials'] = true
      end
    end
  end
end
