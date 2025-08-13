USE crm;

CREATE TABLE IF NOT EXISTS linkedin_leads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    linkedin_id VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    company VARCHAR(255),
    position VARCHAR(255),
    industry VARCHAR(100),
    location VARCHAR(255),
    profile_url TEXT,
    lead_score INT DEFAULT 0,
    status ENUM('new', 'contacted', 'qualified', 'converted', 'lost') DEFAULT 'new',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_linkedin_id (linkedin_id),
    INDEX idx_email (email),
    INDEX idx_company (company),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
); 