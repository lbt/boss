source "https://rubygems.org" do
  gem "rspec", :require => "spec" 
  gem "inifile"
  gem "yajl-ruby", ">=1.3.0"
  gem "bunny"
end
# That's it for our strict dependencies. However, we also want to
# ensure we're using specific git versions from things further down the tree.
# To use local checkout: bundle config local.$GEMNAME /path/to/checkout
# Specify refs to pin the git. Local checkouts will use the branch

gem "ruote", :git => "https://github.com/MeeGoIntegration/ruote.git", :ref => "30a6bb88"
gem "ruote-kit", :git => "https://github.com/MeeGoIntegration/ruote-kit.git", :branch => "master"

gemspec
