# Disable asset fingerprinting for development
Rails.application.config.assets.version = nil

# Add esbuild output path to asset load path
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
