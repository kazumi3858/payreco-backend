# frozen_string_literal: true

module Api
  module V1
    class WorksController < ApplicationController
      def index
        works = current_user.works.order(:date, :starting_time, :created_at)
        render json: works
      end

      def create
        work = current_user.works.new(work_params)
        if work.save
          render json: work, status: :created
        else
          render json: work.errors, status: :unprocessable_entity
        end
      end

      def update
        set_work
        if @work.update(work_params)
          render json: @work
        else
          render json: @work.errors, status: :unprocessable_entity
        end
      end

      def destroy
        set_work
        @work.destroy
        head :no_content
      end

      private

      def set_work
        @work = current_user.works.find(params[:id])
      end

      def work_params
        params.require(:work).permit(:date, :starting_time, :ending_time, :break_time, :working_hours,
                                     :pay_amount, :memo, :user_id, :company_id)
      end
    end
  end
end
