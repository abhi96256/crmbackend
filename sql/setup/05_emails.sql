-- =====================================================
-- CRM Database Setup - Email Management
-- File: 05_emails.sql
-- Description: Email tracking and management tables
-- =====================================================

USE crm;

-- Create emails table
CREATE TABLE IF NOT EXISTS emails (
  id INT AUTO_INCREMENT PRIMARY KEY,
  from_email VARCHAR(255) NOT NULL,
  to_email VARCHAR(255) NOT NULL,
  subject VARCHAR(500),
  body TEXT,
  status ENUM('sent', 'delivered', 'failed', 'bounced') DEFAULT 'sent',
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  delivered_at TIMESTAMP NULL,
  user_id INT,
  lead_id INT NULL,
  template_id VARCHAR(100) NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create email templates table
CREATE TABLE IF NOT EXISTS email_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  subject VARCHAR(500),
  body TEXT NOT NULL,
  variables JSON,
  is_active BOOLEAN DEFAULT TRUE,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create email tracking table
CREATE TABLE IF NOT EXISTS email_tracking (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email_id INT NOT NULL,
  event_type ENUM('open', 'click', 'bounce', 'spam') NOT NULL,
  event_data JSON,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (email_id) REFERENCES emails(id) ON DELETE CASCADE
);

-- Create email campaigns table
CREATE TABLE IF NOT EXISTS email_campaigns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  subject VARCHAR(500),
  body TEXT NOT NULL,
  status ENUM('draft', 'scheduled', 'active', 'paused', 'completed') DEFAULT 'draft',
  scheduled_at TIMESTAMP NULL,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert default email templates
INSERT IGNORE INTO email_templates (name, subject, body, created_by) VALUES
('Welcome Email', 'Welcome to our CRM System', 'Hi {{name}},\n\nWelcome to our CRM system! We are excited to have you on board.\n\nBest regards,\nCRM Team', 1),
('Lead Follow Up', 'Following up on your inquiry', 'Hi {{name}},\n\nThank you for your interest. I wanted to follow up on your inquiry.\n\nBest regards,\n{{user_name}}', 1);

-- Log emails setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'EMAILS_SETUP', 'Email management system initialized', '127.0.0.1');

