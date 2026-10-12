# frozen_string_literal: true

require_relative "../../config/environment"
require_relative "../concerns/block_footer_daemon_helper"

include BlockFooterDaemonHelper

run_block_footer_daemon("alpenglow-community")
