class DataCentersController < ApplicationController

  # index_params[:network]
  # index_params[:sort_by]
  def index
    @sort_by = index_params[:sort_by] == 'asn' ? 'asn' : 'data_center'
    @results = SortedDataCenters.new(
      sort_by: @sort_by, 
      network: params[:network]
    ).call

    if @sort_by == 'asn'
      @asn_stat = AsnStat.where(network: params[:network])
    end
  end

  # params[:network]
  # params[:key]
  def data_center
    key = show_params[:key].gsub('-slash-', '/')

    @per = 25

    @filter_by = show_params[:filter_by].blank? ? Validator.default_filters(params[:network]) : show_params[:filter_by]

    data_centers = DataCenter.where(data_center_key: key)
    @validators = Validator.joins(:validator_score_v1, :data_center)
                           .where(
                             "data_centers.id IN (?)
                             AND validators.is_active = true
                             AND validator_score_v1s.network = ? 
                             AND validator_score_v1s.active_stake > ?",
                             data_centers.ids, show_params[:network], 0
                           )
                           .includes(:validator_score_v1, :data_center_host, :stake_pools)
                           .filtered_by(@filter_by)
                           .order("validator_score_v1s.active_stake desc")

    @dc_stake = @validators.sum(:active_stake)          
    @validators = @validators.page(params[:page]).per(@per)
    @batch = Batch.last_scored(params[:network])
    @population = @validators.total_count
    @total_stake = ValidatorScoreV1.total_active_stake(params[:network])
    @dc_info = data_centers.first || DataCenter.new(data_center_key: key)
  end

  private

  def index_params
    params.permit(:network, :sort_by)
  end

  def show_params
    params.permit(:network, :page, :key, filter_by: [])
  end
end
