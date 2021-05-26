FactoryBot.define do
  factory :ip do
    address { Faker::Internet.ip_v4_address }
    continent_code { 'AS' }
    continent_geoname_id { 6255147 }
    continent_name { 'Asia' }
    country_confidence { 99 }
    country_geoname_id { 1814991 }
    country_name { 'China' }
    registered_country_iso_code { 'CN' }
    registered_country_geoname_id { 1814991 }
    registered_country_name { 'China' }
    traits_anonymous { true }
    traits_hosting_provider { true }
    traits_user_type { 'hosting' }
    traits_autonomous_system_number { 00000 }
    traits_isp { 'Organization' }
    traits_organization { 'Organization' }
    location_time_zone { 'Asia/Shanghai' }

    factory :ip_berlin do
      traits_autonomous_system_number { 54321 }
      data_center_key { '54321-DE-Europe/Berlin' }
      traits_autonomous_system_organization { 'Berlin Organisation' }
      country_iso_code { 'DE' }
    end

    factory :ip_china do
      traits_autonomous_system_number { 12345 }
      data_center_key { '12345-CN-Asia/Shanghai' }
      traits_autonomous_system_organization { 'Chinese Organisation' }
      country_iso_code { 'CN' }
    end
  end
end
