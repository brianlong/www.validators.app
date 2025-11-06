// Application configuration and asset path management
class AppConfig {
  constructor() {
    this.config = null;
    this.assets = null;
  }

  // Initialize configuration from server-side data
  init(configData) {
    this.config = configData;
    this.assets = configData.assets || {};
    
    // Make config globally accessible for backward compatibility
    window.api_authorization = this.config.api_authorization;
    window.google_maps_api_key = this.config.google_maps_api_key;
    window.default_avatar_url = this.getAssetPath('default-avatar.png');
    window.agave_icon_url = this.getAssetPath('agave.svg');
    window.firedancer_icon_url = this.getAssetPath('firedancer.svg');
    window.loading_gif_url = this.getAssetPath('loading.gif');
    
    // Provide global asset path helper for backward compatibility
    window.asset_path_helper = (filename) => this.getAssetPath(filename);
  }

  // Get asset path with digest hash
  getAssetPath(filename) {
    return this.assets[filename] || `/assets/${filename}`;
  }

  // Get API authorization token
  getApiAuth() {
    return this.config?.api_authorization;
  }

  // Get Google Maps API key
  getGoogleMapsKey() {
    return this.config?.google_maps_api_key;
  }

  // Get all asset paths
  getAssetPaths() {
    return this.assets;
  }
}

// Create and export singleton instance
const appConfig = new AppConfig();

// Auto-initialize if config is available in the DOM
document.addEventListener('DOMContentLoaded', () => {
  const configElement = document.getElementById('app-config-data');
  if (configElement) {
    try {
      const configData = JSON.parse(configElement.textContent);
      appConfig.init(configData);
    } catch (error) {
      console.error('Failed to parse app configuration:', error);
    }
  }
});

export default appConfig;
