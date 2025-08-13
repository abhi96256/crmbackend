-- Update users table to include 'employee' role
ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'user', 'manager', 'employee') DEFAULT 'user';

-- Add some sample employees for testing
INSERT INTO users (name, email, password, role) VALUES 
('Test Employee 1', 'employee1@test.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee'),
('Test Employee 2', 'employee2@test.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee')
ON DUPLICATE KEY UPDATE id=id; 