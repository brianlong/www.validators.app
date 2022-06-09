# frozen_string_literal: true
User.where("created_at < ?", User::CONFIRMATION_TIME.ago).where(confirmed_at: nil).each(&:destroy)
