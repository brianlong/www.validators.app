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

    trait :seychelles do
      continent_code { "AF" } 
      continent_geoname_id { 6255146 } 
      continent_name { "Africa" } 
      country_confidence { 99 } 
      country_iso_code { "SC" } 
      country_geoname_id { 241170 } 
      country_name { "Seychelles" } 
      registered_country_iso_code { "SC" } 
      registered_country_geoname_id { 241170 } 
      registered_country_name { "Seychelles" } 
      traits_anonymous { false } 
      traits_hosting_provider { false } 
      traits_user_type { "residential" } 
      traits_autonomous_system_number { 206264 } 
      traits_autonomous_system_organization { "Amarutu Technology Ltd" } 
      traits_isp { "Amarutu Technology Ltd" } 
      traits_organization { "Amarutu Technology Ltd" } 
      city_confidence { nil } 
      city_geoname_id { nil } 
      city_name { nil } 
      location_average_income { nil } 
      location_population_density { nil } 
      location_accuracy_radius { 50 } 
      location_latitude { -0.45833e1 } 
      location_longitude { 0.556667e2 } 
      location_metro_code { nil } 
      location_time_zone { "Indian/Mahe" } 
      postal_confidence { nil } 
      postal_code { nil }
      subdivision_confidence { nil } 
      subdivision_iso_code { nil } 
      subdivision_geoname_id { nil }
      subdivision_name { nil } 
      data_center_key { "206264-SC-Indian/Mahe" }
    end

    trait :netherlands do
      continent_code { "EU" }
      continent_geoname_id { 6255148 }
      continent_name { "Europe" }
      country_confidence { 99 }
      country_iso_code { "NL" }
      country_geoname_id { 2750405 }
      country_name { "Netherlands" }
      registered_country_iso_code { "SC" }
      registered_country_geoname_id { 241170 }
      registered_country_name { "Seychelles" }
      traits_anonymous { false }
      traits_hosting_provider { false }
      traits_user_type { "residential" }
      traits_autonomous_system_number { 206264 }
      traits_autonomous_system_organization { "Amarutu Technology Ltd" }
      traits_isp { "Amarutu Technology Ltd" }
      traits_organization { "Amarutu Technology Ltd" }
      city_confidence { 1 }
      city_geoname_id { 2759794 }
      city_name { "Amsterdam" }
      location_average_income { nil }
      location_population_density { nil }
      location_accuracy_radius { 50 }
      location_latitude { 0.523759e2 }
      location_longitude { 0.48975e1 }
      location_metro_code { nil }
      location_time_zone { "Europe/Amsterdam" }
      postal_confidence { 1 }
      postal_code { "1012" }
      subdivision_confidence { 1 }
      subdivision_iso_code { "NH" }
      subdivision_geoname_id { 2749879 }
      subdivision_name { 0 }
      data_center_key { "206264-NL-Amsterdam" }
    end
  end
end
