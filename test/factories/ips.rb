# frozen_string_literal: true

FactoryBot.define do
  factory :ip do
    address { Faker::Internet.ip_v4_address }
    traits_anonymous { true }
    traits_hosting_provider { true }
    traits_user_type { 'hosting' }
    traits_autonomous_system_number { 00000 }
    traits_isp { 'Organization' }
    traits_organization { 'Organization' }

    trait :ip_berlin do
      continent_code { 'EU' }
      country_confidence { 99 }
      country_geoname_id { 276 }
      country_iso_code { 'DE' }
      continent_name { 'Europe' }
      country_name { 'Germany' }
      data_center_key { '54321-DE-Europe/Berlin' }
      location_time_zone { 'Europe/CET' }
      registered_country_iso_code { 'DE' }
      registered_country_geoname_id { 276 }
      registered_country_name { 'Germany' }
      traits_autonomous_system_number { 54321 }
      traits_autonomous_system_organization { 'Berlin Organisation' }
    end

    trait :ip_china do
      continent_code { 'AS' }
      continent_geoname_id { 6255147 }
      continent_name { 'Asia' }
      country_confidence { 99 }
      country_geoname_id { 1814991 }
      country_iso_code { 'CN' }
      country_name { 'China' }
      data_center_key { '12345-CN-Asia/Shanghai' }
      location_time_zone { 'Asia/Shanghai' }
      registered_country_iso_code { 'CN' }
      registered_country_geoname_id { 1814991 }
      registered_country_name { 'China' }
      traits_autonomous_system_number { 12345 }
      traits_autonomous_system_organization { 'Chinese Organisation' }
    end
  end
end
