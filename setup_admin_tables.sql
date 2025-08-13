-- Admin Dashboard Tables Setup

-- Advertisements table
CREATE TABLE IF NOT EXISTS advertisements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    target_audience VARCHAR(255),
    budget DECIMAL(10,2),
    views INT DEFAULT 0,
    clicks INT DEFAULT 0,
    status ENUM('active', 'inactive', 'draft') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Packages table
CREATE TABLE IF NOT EXISTS packages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    features JSON,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User packages subscription table
CREATE TABLE IF NOT EXISTS user_packages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    package_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('active', 'expired', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);

-- User permissions table
CREATE TABLE IF NOT EXISTS user_permissions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    permission_name VARCHAR(255) NOT NULL,
    status ENUM('granted', 'pending', 'denied') DEFAULT 'pending',
    granted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- User tokens table
CREATE TABLE IF NOT EXISTS user_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    tokens_used INT DEFAULT 0,
    tokens_allocated INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    package_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(100),
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE SET NULL
);

-- Insert sample data
INSERT INTO packages (name, description, price, features, status) VALUES
('Basic', 'Essential features for small businesses', 999.00, '["Lead Management", "Basic Analytics", "Email Support"]', 'active'),
('Premium', 'Advanced features for growing businesses', 1999.00, '["Lead Management", "Advanced Analytics", "Priority Support", "Custom Reports"]', 'active'),
('Enterprise', 'Complete solution for large organizations', 4999.00, '["Lead Management", "Advanced Analytics", "Priority Support", "Custom Reports", "API Access", "Dedicated Manager"]', 'active');

-- Add missing columns to users table (skip if already exist)
-- ALTER TABLE users ADD COLUMN role ENUM('admin', 'user', 'client') DEFAULT 'user';
-- ALTER TABLE users ADD COLUMN status ENUM('active', 'inactive', 'suspended') DEFAULT 'active';
-- ALTER TABLE users ADD COLUMN last_login TIMESTAMP NULL;
-- ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500);

-- Create admin user if not exists
INSERT INTO users (name, email, password, role, status) 
SELECT 'Admin User', 'admin@company.com', '$2b$10$rQZ8K9vX2mN3pL4qR5sT6u', 'admin', 'active'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@company.com'); 