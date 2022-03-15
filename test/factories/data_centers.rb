# frozen_string_literal: true

FactoryBot.define do
  factory :data_center do
    traits_anonymous { true }
    traits_hosting_provider { true }
    traits_user_type { "hosting" }
    traits_autonomous_system_number { 00000 }
    traits_isp { "Organization" }
    traits_organization { "Organization" }

    trait :berlin do
      city_name { "Berlin" }
      continent_code { "EU" }
      country_confidence { 99 }
      country_geoname_id { 276 }
      country_iso_code { "DE" }
      continent_name { "Europe" }
      country_name { "Germany" }
      location_time_zone { "Europe/CET" }
      registered_country_iso_code { "DE" }
      registered_country_geoname_id { 276 }
      registered_country_name { "Germany" }
      traits_autonomous_system_number { 12345 }
      traits_autonomous_system_organization { "Germany Organisation" }
      traits_organization { "Germany Organisation" }
      traits_isp { "Germany ISP" }
      location_latitude { 0.512993e2 }
      location_longitude { 0.9491e1 }
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
      location_time_zone { "Europe/CET" }
      registered_country_iso_code { "DE" }
      registered_country_geoname_id { 276 }
      registered_country_name { "Germany" }
      traits_autonomous_system_number { 12345 }
      traits_autonomous_system_organization { "Germany Organisation" }
      traits_organization { "Germany Organisation" }
      traits_isp { "Germany ISP" }
      location_latitude {  0.488582e2 }
      location_longitude { 0.23387e1 }
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
      location_time_zone { "Asia/Shanghai" }
      registered_country_iso_code { "CN" }
      registered_country_geoname_id { 1814991 }
      registered_country_name { "China" }
      traits_autonomous_system_number { 54321 }
      traits_autonomous_system_organization { "Chinese Organisation" }
      traits_organization { "Chinese Organisation" }
      traits_isp { "Chinese ISP" }
      location_latitude { 1 }
      location_longitude { 2 }
    end
  end
end
