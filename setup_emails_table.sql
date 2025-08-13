-- Create emails table for storing inbox, sent, and trash emails
CREATE TABLE IF NOT EXISTS emails (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('inbox', 'sent', 'trash') NOT NULL,
    from_email VARCHAR(255),
    from_name VARCHAR(255),
    to_email VARCHAR(255),
    to_name VARCHAR(255),
    subject VARCHAR(500) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_starred BOOLEAN DEFAULT FALSE,
    has_attachment BOOLEAN DEFAULT FALSE,
    priority ENUM('low', 'normal', 'high') DEFAULT 'normal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_type (user_id, type),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at),
    INDEX idx_is_read (is_read),
    INDEX idx_is_starred (is_starred)
);

-- Insert some sample emails for testing
INSERT INTO emails (user_id, type, from_email, from_name, to_email, to_name, subject, message, is_read, is_starred, has_attachment, priority) VALUES
(1, 'inbox', 'support@crm.com', 'CRM Support Team', NULL, NULL, 'Welcome to CRM - Getting Started Guide', 'Hi there! Welcome to our CRM system. We''re excited to have you on board. This email contains important information to help you get started with our platform. You''ll find tutorials, best practices, and tips to make the most of your CRM experience. If you have any questions, feel free to reach out to our support team.', FALSE, TRUE, TRUE, 'high'),
(1, 'inbox', 'info@company.com', 'Company Finance', NULL, NULL, 'Your Invoice #INV-2024-001', 'Dear valued customer, Please find attached your invoice for the services provided. The total amount due is $1,250.00. Payment is due within 30 days. You can pay online through our secure payment portal or contact our billing department for alternative payment methods.', TRUE, FALSE, TRUE, 'normal'),
(1, 'inbox', 'marketing@techcorp.com', 'TechCorp Marketing', NULL, NULL, 'New Product Launch - Exclusive Early Access', 'We''re thrilled to announce our latest product launch! As a valued customer, you get exclusive early access to our new AI-powered analytics dashboard. This revolutionary tool will transform how you analyze your business data and make informed decisions.', FALSE, FALSE, FALSE, 'normal'),
(1, 'inbox', 'hr@company.com', 'Human Resources', NULL, NULL, 'Monthly Team Meeting - July 2024', 'Hello team! This is a reminder about our monthly team meeting scheduled for Friday, July 26th at 2:00 PM. We''ll be discussing Q3 goals, upcoming projects, and team updates. Please prepare your updates and join us in the conference room.', TRUE, FALSE, FALSE, 'normal'),
(1, 'inbox', 'alerts@security.com', 'Security Alerts', NULL, NULL, 'Security Update Required - Action Needed', 'IMPORTANT: We detected unusual login activity on your account. For your security, we recommend changing your password immediately. Click the link below to reset your password securely. If you didn''t attempt this login, please contact our security team.', FALSE, TRUE, FALSE, 'high'),
(1, 'sent', 'admin@crm.com', 'Admin User', 'john@example.com', 'John Smith', 'Project Update - Q3 Goals', 'Hi John, I wanted to provide you with an update on our Q3 project goals. We''ve made significant progress on the CRM integration and are on track to meet our deadlines. Let me know if you need any additional information.', TRUE, FALSE, FALSE, 'normal'),
(1, 'sent', 'admin@crm.com', 'Admin User', 'jane@example.com', 'Jane Doe', 'Invoice Sent - Payment Confirmation', 'Hi Jane, I''ve sent the invoice for our recent project. The total amount is $2,500.00. Please review and let me know if you have any questions. Payment is due within 30 days.', TRUE, FALSE, FALSE, 'normal');

-- Insert some sample trash emails for testing
INSERT INTO emails (user_id, type, from_email, from_name, to_email, to_name, subject, message, is_read, is_starred, has_attachment, priority, deleted_at) VALUES
(1, 'trash', 'old@company.com', 'Old Company', NULL, NULL, 'Old Project Details', 'This is an old email that was deleted. It contains outdated project information that is no longer relevant.', TRUE, FALSE, FALSE, 'normal', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, 'trash', 'spam@example.com', 'Spam Sender', NULL, NULL, 'Spam Email - Deleted', 'This was a spam email that was deleted. It contained unwanted promotional content.', FALSE, FALSE, FALSE, 'normal', DATE_SUB(NOW(), INTERVAL 10 DAY)); 