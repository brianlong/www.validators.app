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

    @per = 25

    @scores = ValidatorScoreV1.by_network_with_active_stake(show_params[:network])
                              .includes(:validator)
                              .by_data_centers(key)
                              .filtered_by(show_params[:filter_by]&.to_sym)
                              .order('active_stake desc')

    if params[:show_private]
      @scores = @scores.with_private(show: params[:show_private])
    end
    
    @dc_stake = @scores.where(data_center_key: key).sum(:active_stake)
          
    @scores = @scores.page(params[:page])
                    .per(@per)

    @validators = @scores.map(&:validator).compact

    @batch = Batch.last_scored(params[:network])

    @population = @scores.total_count

    @total_stake = ValidatorScoreV1.by_network_with_active_stake(params[:network])
                                   .sum(:active_stake)
                                   
    @dc_info = Ip.where(data_center_key: key).last || Ip.new(data_center_key: key)
  end

  private

  def index_params
    params.permit(:network, :sort_by)
  end

  def show_params
    params.permit(:network, :page, :key, :filter_by)
  end
end
