# frozen_string_literal: true

yellowstone_grpc_path = Rails.root.join("lib", "yellowstone_grpc").to_s
$LOAD_PATH.unshift(yellowstone_grpc_path) unless $LOAD_PATH.include?(yellowstone_grpc_path)
