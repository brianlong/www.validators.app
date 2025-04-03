module Api::V1
  class VoteController < BaseController
    def block_list
      limit = [(vote_params[:limit] || 100).to_i, 999].min
      if vote_params[:network]
        block_list = Blockchain::Block.network(vote_params[:network]).order(slot_number: :desc).limit(limit)
        json_result = block_list.map { |block| block.to_builder.attributes! }

        respond_to do |format|
          format.json { render json: json_result, status: :ok }
        end
      else
        render json: { error: 'Invalid network' }, status: :bad_request
      end
    end

    def block_details
      if vote_params[:block_hash] && vote_params[:network]
        block = Blockchain::Block.network(vote_params[:network]).find_by(blockhash: vote_params[:block_hash])
        if block
          limit = [(vote_params[:limit] || 500).to_i, 9999].min
          transactions = block.transactions.page(vote_params[:page]).per(limit)
          json_result = block.to_builder.attributes!
          json_result[:transactions] = transactions.map { |tx| tx.to_builder.attributes! }

          respond_to do |format|
            format.json { render json: json_result, status: :ok }
          end
        else
          render json: { error: 'Block not found' }, status: :not_found
        end
      else
        render json: { error: 'Invalid block hash or network' }, status: :bad_request
      end
    end

    private

    def vote_params
      params.permit(:block_hash, :network, :limit, :page)
    end
  end
end
