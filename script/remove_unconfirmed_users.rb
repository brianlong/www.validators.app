# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

User.where("created_at < ?", User::CONFIRMATION_TIME.ago)
    .where(confirmed_at: nil)
    .destroy_all
