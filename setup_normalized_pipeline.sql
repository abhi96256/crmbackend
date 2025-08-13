-- Normalized Pipeline Schema
-- This replaces the JSON-based pipeline storage with proper relational tables

-- Create pipelines table
CREATE TABLE IF NOT EXISTS pipelines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL DEFAULT 'Sales Pipeline',
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  is_default BOOLEAN DEFAULT FALSE,
  created_by INT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create pipeline_stages table
CREATE TABLE IF NOT EXISTS pipeline_stages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pipeline_id INT NOT NULL,
  stage_key VARCHAR(100) NOT NULL,
  stage_name VARCHAR(255) NOT NULL,
  stage_order INT NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  is_custom BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pipeline_id) REFERENCES pipelines(id) ON DELETE CASCADE,
  UNIQUE KEY unique_stage_order (pipeline_id, stage_order)
);

-- Create pipeline_hints table
CREATE TABLE IF NOT EXISTS pipeline_hints (
  id INT AUTO_INCREMENT PRIMARY KEY,
  stage_id INT NOT NULL,
  hint_type ENUM('beginner', 'intermediate', 'expert') NOT NULL,
  hint_text TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (stage_id) REFERENCES pipeline_stages(id) ON DELETE CASCADE,
  UNIQUE KEY unique_stage_hint (stage_id, hint_type)
);

-- Insert default pipeline
INSERT INTO pipelines (name, description, is_default, created_by) VALUES 
('Sales Pipeline', 'Default sales pipeline for lead management', TRUE, 1)
ON DUPLICATE KEY UPDATE id=id;

-- Get the default pipeline ID
SET @default_pipeline_id = (SELECT id FROM pipelines WHERE is_default = TRUE LIMIT 1);

-- Insert default stages
INSERT INTO pipeline_stages (pipeline_id, stage_key, stage_name, stage_order, is_default) VALUES
(@default_pipeline_id, 'initialContact', 'Initial Contact', 1, TRUE),
(@default_pipeline_id, 'discussions', 'Discussions', 2, TRUE),
(@default_pipeline_id, 'decisionMaking', 'Decision Making', 3, TRUE),
(@default_pipeline_id, 'contractDiscussion', 'Contract Discussion', 4, TRUE),
(@default_pipeline_id, 'closedWon', 'Deal - won', 5, TRUE),
(@default_pipeline_id, 'closedLost', 'Deal - lost', 6, TRUE)
ON DUPLICATE KEY UPDATE stage_name = VALUES(stage_name);

-- Insert default hints for each stage
INSERT INTO pipeline_hints (stage_id, hint_type, hint_text) VALUES
((SELECT id FROM pipeline_stages WHERE stage_key = 'discussions' AND pipeline_id = @default_pipeline_id), 'beginner', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'discussions' AND pipeline_id = @default_pipeline_id), 'intermediate', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'discussions' AND pipeline_id = @default_pipeline_id), 'expert', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'decisionMaking' AND pipeline_id = @default_pipeline_id), 'beginner', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'decisionMaking' AND pipeline_id = @default_pipeline_id), 'intermediate', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'decisionMaking' AND pipeline_id = @default_pipeline_id), 'expert', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'contractDiscussion' AND pipeline_id = @default_pipeline_id), 'beginner', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'contractDiscussion' AND pipeline_id = @default_pipeline_id), 'intermediate', 'Add hints'),
((SELECT id FROM pipeline_stages WHERE stage_key = 'contractDiscussion' AND pipeline_id = @default_pipeline_id), 'expert', 'Add hints')
ON DUPLICATE KEY UPDATE hint_text = VALUES(hint_text); 