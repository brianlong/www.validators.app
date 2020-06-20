# frozen_string_literal: true

json.extract! validator, :id, :network, :account, :name, :keybase_id, :www_url, :created_at, :updated_at
json.url api_v1_validator_url(network: params[:network], account: validator.account, format: :json)
