const axios = require('axios');

console.log('🧪 Testing BYPASS Login - Any password should work!');
console.log('==================================================');

const BASE_URL = 'https://crmbackend-fahc.onrender.com';

const testBypassLogin = async () => {
  try {
    console.log('🔓 Testing login with ANY password...');
    
    // Test 1: Login with any email and password
    const loginData = {
      email: 'test@example.com',
      password: 'ANY_PASSWORD_WILL_WORK'
    };
    
    console.log('📤 Login data:', loginData);
    
    const response = await axios.post(`${BASE_URL}/api/auth/login`, loginData);
    
    console.log('✅ BYPASS LOGIN SUCCESSFUL!');
    console.log('📊 Response status:', response.status);
    console.log('📋 Response data:', response.data);
    
    if (response.data.token) {
      console.log('🔑 Token received:', response.data.token.substring(0, 20) + '...');
      console.log('👤 User data:', response.data.user);
      
      // Test 2: Try to get user profile with the token
      console.log('\n🔓 Testing /me endpoint with token...');
      
      const profileResponse = await axios.get(`${BASE_URL}/api/auth/me`, {
        headers: {
          'Authorization': `Bearer ${response.data.token}`
        }
      });
      
      console.log('✅ Profile endpoint working!');
      console.log('👤 Profile data:', profileResponse.data);
      
    }
    
    console.log('\n🎉 BYPASS LOGIN SYSTEM IS WORKING!');
    console.log('🔓 ANY email + ANY password = SUCCESS');
    console.log('⚠️  REMEMBER: This is temporary - remove in production!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    if (error.response) {
      console.error('📊 Response status:', error.response.status);
      console.error('📋 Response data:', error.response.data);
    }
    
    console.log('\n🔧 Troubleshooting:');
    console.log('1. Make sure your backend is running on Render');
    console.log('2. Check if the bypass auth route is properly loaded');
    console.log('3. Verify the server.js changes were applied');
  }
};

// Run the test
testBypassLogin();

