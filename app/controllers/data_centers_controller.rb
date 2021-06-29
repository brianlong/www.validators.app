class DataCentersController < ApplicationController

  # index_params[:network]
  # index_params[:sort_by]
  def index
    @sort_by = index_params[:sort_by] == 'asn' ? 'asn' : 'data_center'
    @results = SortedDataCenters.new(
      sort_by: @sort_by, 
      network: params[:network]
    ).call
  end

  # params[:network]
  # params[:key]
  def data_center
    key = params[:key].gsub('-slash-', '/')
    # sql = "
    #   SELECT *
    #   FROM validators val
    #   INNER JOIN validator_score_v1s score ON val.id = score.validator_id
    #   WHERE score.network = '#{params[:network]}'
    #   AND score.active_stake > 0
    #   AND score.ip_address IN (
    #     SELECT ip_address from ips
    #     WHERE data_center_key = '#{key}'
    #   )
    #   ORDER BY val.account
    # "
    # @validators = Validator.connection.execute(sql)
    @batch = Batch.last_scored(params[:network])
    @scores = ValidatorScoreV1.by_network_with_active_stake(params[:network])
                              .includes(:validator)
                              .by_data_centers(key)
                              .order('active_stake desc')
                              .page(params[:page])
                              .per(20)

    @total_stake = ValidatorScoreV1.by_network_with_active_stake(params[:network])
                                   .sum(:active_stake)

    @dc_stake = @scores.where(data_center_key: key).sum(:active_stake)
    @dc_info = Ip.where(data_center_key: key).last || Ip.new(data_center_key: key)
  end

  private

  def index_params
    params.permit(:network, :sort_by)
  end
end
