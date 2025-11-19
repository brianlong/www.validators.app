# frozen_string_literal: true

namespace :assets do
  desc "Build JavaScript assets using esbuild (alias for javascript:build)"
  task :build do
    system('npm run build') || exit(1)
  end

  desc "Precompile assets for tests"
  task :test_precompile do
    system('npm run build') || exit(1)
  end

  # Hook into the standard Rails assets:precompile task
  task :precompile => :build
end
