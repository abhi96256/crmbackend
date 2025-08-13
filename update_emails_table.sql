-- Update emails table to support trash functionality
-- Add deleted_at column (MySQL doesn't support IF NOT EXISTS for ADD COLUMN)
ALTER TABLE emails ADD COLUMN deleted_at TIMESTAMP NULL;

-- Update type enum to include 'trash'
ALTER TABLE emails MODIFY COLUMN type ENUM('inbox', 'sent', 'trash') NOT NULL;

-- Add index for deleted_at (MySQL doesn't support IF NOT EXISTS for CREATE INDEX)
CREATE INDEX idx_deleted_at ON emails(deleted_at);

-- Insert some sample trash emails for testing
INSERT INTO emails (user_id, type, from_email, from_name, to_email, to_name, subject, message, is_read, is_starred, has_attachment, priority, deleted_at) VALUES
(1, 'trash', 'old@company.com', 'Old Company', NULL, NULL, 'Old Project Details', 'This is an old email that was deleted. It contains outdated project information that is no longer relevant.', TRUE, FALSE, FALSE, 'normal', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(1, 'trash', 'spam@example.com', 'Spam Sender', NULL, NULL, 'Spam Email - Deleted', 'This was a spam email that was deleted. It contained unwanted promotional content.', FALSE, FALSE, FALSE, 'normal', DATE_SUB(NOW(), INTERVAL 10 DAY)); 