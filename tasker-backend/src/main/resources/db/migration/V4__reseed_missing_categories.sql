INSERT INTO service_categories (name, description, icon_name, base_price) VALUES
('Plumbing', 'Pipe repairs, installations, leak fixing', 'plumbing', 1500.00),
('Cleaning', 'Thorough home and office deep cleaning', 'cleaning', 1800.00),
('Electrical', 'Wiring, outlet fixes, electrical troubleshooting', 'electrical', 1800.00),
('Handyman', 'General home maintenance and repairs', 'handyman', 1500.00)
ON CONFLICT (name) DO NOTHING;
