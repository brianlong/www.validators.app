// Pre-configured axios instance with authorization interceptor
import axios from 'axios'

// Create a configured instance
const configuredAxios = axios.create()

// Add authorization interceptor
configuredAxios.interceptors.request.use(function (config) {
  // Only add authorization header if it's a valid string
  if (window.api_authorization && typeof window.api_authorization === 'string') {
    config.headers.Authorization = window.api_authorization;
  }
  return config;
}, function (error) {
  return Promise.reject(error);
});

export default configuredAxios;
