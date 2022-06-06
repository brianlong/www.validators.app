# frozen_string_literal: true

delay_time = 7.days

User.where("created_at < ?", delay_time.ago).where(confirmed_at: nil).delete_all