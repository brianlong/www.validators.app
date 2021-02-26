# Falkenstein
# insert into ip_overrides (address, traits_autonomous_system_number, country_iso_code, country_name, city_name, data_center_key, data_center_host, created_at, updated_at) VALUES ('5.83.175.225', 199610, 'RU', 'Russia', 'Moscow', '199610-RU-Moscow', 'FRNKT-NYC-PE-MX960-1.megafon.ru', NOW(), NOW());
#
# UPDATE ips ip INNER JOIN ip_overrides ipor ON ip.address = ipor.address SET ip.traits_autonomous_system_number = ipor.traits_autonomous_system_number, ip.country_iso_code = ipor.country_iso_code, ip.country_name = ipor.country_name, ip.city_name = ipor.city_name, ip.data_center_key = ipor.data_center_key, ip.data_center_host = ipor.data_center_host, ip.traits_autonomous_system_organization = 'Hetzner Online GmbH', ip.updated_at = NOW();
#
# UPDATE validator_score_v1s sc INNER JOIN ips ip ON sc.ip_address = ip.address SET sc.data_center_key = ip.data_center_key, sc.data_center_host = ip.data_center_host, sc.updated_at = NOW();
