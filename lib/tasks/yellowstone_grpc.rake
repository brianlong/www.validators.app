# frozen_string_literal: true

namespace :yellowstone_grpc do
  desc "Generate Ruby stubs from lib/yellowstone_grpc/proto"
  task :generate do
    root = Rails.root.join("lib", "yellowstone_grpc")
    proto_dir = root.join("proto")
    protos = Dir[proto_dir.join("*.proto")].sort

    system(
      "bundle", "exec", "grpc_tools_ruby_protoc",
      "-I", proto_dir.to_s,
      "--ruby_out=#{root}",
      "--grpc_out=#{root}",
      *protos,
      exception: true
    )
  end
end
