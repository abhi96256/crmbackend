-- Create LinkedIn integrations table
CREATE TABLE IF NOT EXISTS linkedin_integrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  expires_at DATETIME NOT NULL,
  linkedin_user_id VARCHAR(255),
  profile_data JSON,
  last_sync DATETIME,
  total_leads INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add index for faster queries
CREATE INDEX idx_linkedin_expires_at ON linkedin_integrations(expires_at);
CREATE INDEX idx_linkedin_user_id ON linkedin_integrations(linkedin_user_id); 