# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

Validator.where(admin_warning: "Hetzner Data Center").each do |val|
  if val.data_center&.traits_autonomous_system_number != 24940
    val.update(admin_warning: nil)
  end
end
