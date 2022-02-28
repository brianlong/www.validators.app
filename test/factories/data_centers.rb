# frozen_string_literal: true

FactoryBot.define do
  factory :data_center do
    traits_anonymous { true }
    traits_hosting_provider { true }
    traits_user_type { "hosting" }

    trait :berlin do
      city_name { "Berlin" }
      city_confidence { 89 }
      continent_code { "EU" }
      country_confidence { 99 }
      country_geoname_id { 276 }
      country_iso_code { "DE" }
      continent_name { "Europe" }
      country_name { "Germany" }
      data_center_key { "54321-DE-Europe/Berlin" }
      location_time_zone { "Europe/CET" }
      registered_country_iso_code { "DE" }
      registered_country_geoname_id { 276 }
      registered_country_name { "Germany" }
      traits_autonomous_system_number { 12345 }
      traits_autonomous_system_organization { "Germany Organisation" }
      traits_organization { "Germany Organisation" }
      traits_isp { "Germany ISP" }
    end

    trait :frankfurt do
      city_name { "Frankfurt" }
      city_confidence { 77 }
      continent_code { "EU" }
      country_confidence { 99 }
      country_geoname_id { 276 }
      country_iso_code { "DE" }
      continent_name { "Europe" }
      country_name { "Germany" }
      data_center_key { "54321-DE-Europe/Frankfurt" }
      location_time_zone { "Europe/CET" }
      registered_country_iso_code { "DE" }
      registered_country_geoname_id { 276 }
      registered_country_name { "Germany" }
      traits_autonomous_system_number { 12345 }
      traits_autonomous_system_organization { "Germany Organisation" }
      traits_organization { "Germany Organisation" }
      traits_isp { "Germany ISP" }
    end

    trait :china do
      city_name { "Shanghai" }
      city_confidence { 83 }
      continent_code { "AS" }
      continent_geoname_id { 6255147 }
      continent_name { "Asia" }
      country_confidence { 99 }
      country_geoname_id { 1814991 }
      country_iso_code { "CN" }
      country_name { "China" }
      data_center_key { "12345-CN-Asia/Shanghai" }
      location_time_zone { "Asia/Shanghai" }
      registered_country_iso_code { "CN" }
      registered_country_geoname_id { 1814991 }
      registered_country_name { "China" }
      traits_autonomous_system_number { 54321 }
      traits_autonomous_system_organization { "Chinese Organisation" }
      traits_organization { "Chinese Organisation" }
      traits_isp { "Chinese ISP" }
    end
  end
end
