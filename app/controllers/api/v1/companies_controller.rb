# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < ApplicationController
      def index
        companies = current_user.companies.order(updated_at: :DESC)
        render json: companies
      end

      def create
        company = current_user.companies.new(company_params)
        if company.save
          render json: company, status: :created
        else
          render json: company.errors, status: :unprocessable_entity
        end
      end

      def update
        set_company
        if @company.update(company_params)
          render json: @company
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      def destroy
        set_company
        @company.deleted_at = Time.zone.now
        if @company.save
          head :no_content
        else
          render json: @company.errors, status: :unprocessable_entity
        end
      end

      private

      def set_company
        @company = current_user.companies.find(params[:id])
      end

      def company_params
        params.require(:company).permit(:name, :hourly_wage_system, :wage_amount, :currency_type)
      end
    end
  end
end
