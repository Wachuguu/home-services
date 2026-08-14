-- Seed 3 Clients
INSERT INTO users (id, email, password_hash, full_name, phone_number, role, location, address, is_available) VALUES
(uuid_generate_v4(), 'client1@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Alice Client', '0711111111', 'CLIENT', ST_SetSRID(ST_MakePoint(36.7620, -1.3958), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'client2@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Bob Client', '0722222222', 'CLIENT', ST_SetSRID(ST_MakePoint(36.7630, -1.3960), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'client3@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Charlie Client', '0733333333', 'CLIENT', ST_SetSRID(ST_MakePoint(36.7610, -1.3950), 4326)::geography, 'Ongata Rongai, Kajiado', true);

-- Seed 6 Providers
INSERT INTO users (id, email, password_hash, full_name, phone_number, role, location, address, is_available) VALUES
(uuid_generate_v4(), 'dan@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Dan Provider', '0744444444', 'PROVIDER', ST_SetSRID(ST_MakePoint(36.7625, -1.3955), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'eve@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Eve Provider', '0755555555', 'PROVIDER', ST_SetSRID(ST_MakePoint(36.7640, -1.3970), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'frank@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Frank Provider', '0766666666', 'PROVIDER', ST_SetSRID(ST_MakePoint(36.7600, -1.3940), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'grace@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Grace Provider', '0777777777', 'PROVIDER', ST_SetSRID(ST_MakePoint(36.7650, -1.3980), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'hassan@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Hassan Provider', '0788888888', 'PROVIDER', ST_SetSRID(ST_MakePoint(36.7615, -1.3965), 4326)::geography, 'Ongata Rongai, Kajiado', true),
(uuid_generate_v4(), 'irene@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Irene Provider', '0799999999', 'PROVIDER', ST_SetSRID(ST_MakePoint(36.7635, -1.3945), 4326)::geography, 'Ongata Rongai, Kajiado', false);

-- Seed 1 Admin
INSERT INTO users (id, email, password_hash, full_name, phone_number, role, location, address, is_available) VALUES
(uuid_generate_v4(), 'admin@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin User', '0700000000', 'ADMIN', NULL, 'HQ', false);

-- Link Providers to Skills
-- Dan(Plumbing+Electrical)
INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Plumbing'), 5, 2000.00, true
FROM users WHERE email = 'dan@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Electrical Repairs'), 4, 1800.00, true
FROM users WHERE email = 'dan@test.com';

-- Eve(DeepCleaning+Laundry)
INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Deep Cleaning'), 3, 1500.00, true
FROM users WHERE email = 'eve@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Laundry'), 2, 800.00, true
FROM users WHERE email = 'eve@test.com';

-- Frank(Carpentry+Furniture+Mounting)
INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Carpentry'), 10, 3000.00, true
FROM users WHERE email = 'frank@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Furniture Assembly'), 6, 1200.00, true
FROM users WHERE email = 'frank@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Mounting & Installation'), 6, 1000.00, true
FROM users WHERE email = 'frank@test.com';

-- Grace(Painting+Landscaping)
INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'House Painting'), 8, 2500.00, true
FROM users WHERE email = 'grace@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Landscaping'), 5, 2000.00, true
FROM users WHERE email = 'grace@test.com';

-- Hassan(Moving+Roofing+PestControl)
INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Moving & Heavy Lifting'), 4, 3000.00, true
FROM users WHERE email = 'hassan@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Roofing & Gutter Maintenance'), 7, 3500.00, true
FROM users WHERE email = 'hassan@test.com';

INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Pest Control'), 3, 2500.00, true
FROM users WHERE email = 'hassan@test.com';

-- Irene(ApplianceRepair, unavailable)
INSERT INTO provider_skills (provider_id, category_id, experience_years, hourly_rate, verified)
SELECT id, (SELECT id FROM service_categories WHERE name = 'Appliance Repair'), 12, 4000.00, true
FROM users WHERE email = 'irene@test.com';
