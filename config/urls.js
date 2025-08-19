// URL Configuration for different environments
const config = {
  development: {
    baseUrl: 'http://localhost:5000',
    frontendUrl: 'http://localhost:5173',
    linkedinRedirectUri: 'http://localhost:5000/api/linkedin/auth/callback'
  },
  production: {
    baseUrl: 'https://crmbackend-fahc.onrender.com',
    frontendUrl: 'https://your-frontend-url.com', // Update this with your actual frontend URL
    linkedinRedirectUri: 'https://crmbackend-fahc.onrender.com/api/linkedin/auth/callback'
  }
};

// Get current environment
const env = process.env.NODE_ENV || 'development';

// Export the appropriate configuration
const urls = config[env];

// Export individual URLs for convenience
const BASE_URL = urls.baseUrl;
const FRONTEND_URL = urls.frontendUrl;
const LINKEDIN_REDIRECT_URI = urls.linkedinRedirectUri;

module.exports = {
  urls,
  BASE_URL,
  FRONTEND_URL,
  LINKEDIN_REDIRECT_URI
};
