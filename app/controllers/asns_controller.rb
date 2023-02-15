class AsnsController < ApplicationController
  def show
    network = asn_params[:network]

    @filter_by = asn_params[:filter_by].blank? ? Validator.default_filters(params[:network]) : asn_params[:filter_by]

    @data_centers = DataCenter.joins(:validator_score_v1s)
                              .where(traits_autonomous_system_number: asn_params[:asn])
                              .where("validator_score_v1s.network = ? AND validator_score_v1s.active_stake > ?", network, 0)
                              .pluck(:id, :data_center_key)
                              .uniq

    data_center_ids = @data_centers.map { |dc| dc[0] }
    @data_center_keys = @data_centers.map { |dc| dc[1] }.uniq

    render file: "#{Rails.root}/public/404.html", layout: nil, status: 404 if @data_centers.empty?

    @per = 25

    @validators = Validator.joins(:validator_score_v1, :data_center)
                           .preload(:validator_score_v1, :data_center_host)
                           .where(
                             "data_centers.id IN (?)
                             AND validators.is_active = true
                             AND validator_score_v1s.network = ? 
                             AND validator_score_v1s.active_stake > ?",
                             data_center_ids, asn_params[:network], 0
                           )
                           .filtered_by(@filter_by)
                           .order("validator_score_v1s.active_stake desc")
    
    @asn_stake = @validators.sum(:active_stake)
    @validators = @validators.page(params[:page]).per(@per)
    @batch = Batch.last_scored(network)
    @population = @validators.total_count
    @total_stake = ValidatorScoreV1.total_active_stake(network)
  end

  private

  def asn_params
    params.permit :asn, :network, :page, filter_by: []
  end
end
