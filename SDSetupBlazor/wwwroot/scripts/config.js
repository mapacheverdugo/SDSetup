// Configuration for SDSetup
// This file makes environment variables available to the Blazor application

// Set the backend URL from environment variable or use default
window.SDSETUP_BACKEND_URL = window.SDSETUP_BACKEND_URL || 'http://localhost:5000';

// You can add more configuration variables here as needed
console.log('SDSetup Backend URL:', window.SDSETUP_BACKEND_URL); 