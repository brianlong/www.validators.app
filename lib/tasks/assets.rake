# frozen_string_literal: true

namespace :assets do
  desc "Build JavaScript assets using esbuild (alias for javascript:build)"
  task :build do
    Rake::Task["javascript:build"].invoke
  end

  desc "Precompile assets for tests"
  task :test_precompile do
    Rake::Task["javascript:build"].invoke
  end
end
