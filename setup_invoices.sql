-- Create invoices table
USE crm;

CREATE TABLE IF NOT EXISTS invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id VARCHAR(50) UNIQUE NOT NULL,
  client_name VARCHAR(255) NOT NULL,
  client_email VARCHAR(255),
  amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('Draft', 'Sent', 'Paid', 'Overdue', 'Cancelled') DEFAULT 'Draft',
  due_date DATE,
  description TEXT,
  assigned_to VARCHAR(255),
  priority ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
  pipeline VARCHAR(100) DEFAULT 'Sales Pipeline',
  stage VARCHAR(100) DEFAULT 'Initial Contact',
  tags JSON DEFAULT '[]',
  files JSON DEFAULT '[]',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample invoices
INSERT INTO invoices (invoice_id, client_name, client_email, amount, total, status, due_date, description, assigned_to, priority, pipeline, stage, tags) VALUES 
('INV-001', 'John Doe', 'john@example.com', 1770.00, 1770.00, 'Paid', '2024-02-15', 'Website development services', 'Amit Sharma', 'High', 'Sales Pipeline', 'Closed', '["urgent", "website"]'),
('INV-002', 'Jane Smith', 'jane@example.com', 2850.00, 2850.00, 'Sent', '2024-02-20', 'Mobile app development', 'Priya Singh', 'Medium', 'Sales Pipeline', 'Proposal', '["mobile", "app"]'),
('INV-003', 'Mike Johnson', 'mike@example.com', 1180.00, 1180.00, 'Overdue', '2024-02-10', 'Consulting services', 'Akash Kumar', 'High', 'Sales Pipeline', 'Negotiation', '["consulting", "urgent"]')
ON DUPLICATE KEY UPDATE id=id; 