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

    window.default_avatar_url = this.getAssetPath('default-avatar.png');
    window.agave_icon_url = this.getAssetPath('agave.svg');
    window.firedancer_icon_url = this.getAssetPath('firedancer.svg');
    window.loading_gif_url = this.getAssetPath('loading.gif');
    window.jito_svg_url = this.getAssetPath('jito.svg');
    window.doublezero_svg_url = this.getAssetPath('doublezero.svg');
    window.doublezero_legacy_svg_url = this.getAssetPath('doublezero_legacy.svg');
    
    // Provide global asset path helper for backward compatibility
    window.asset_path_helper = (filename) => this.getAssetPath(filename);
  }

  // Get asset path with digest hash
  getAssetPath(filename) {
    return this.assets[filename] || `/assets/${filename}`;
  }
}

// Create and export singleton instance
const appConfig = new AppConfig();

export default appConfig;
