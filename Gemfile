source "http://rubygems.org" do
  gem "rspec", :require => "spec" 
  gem "inifile"
  gem "yajl-ruby", ">=1.3.0"
end
# That's it for our strict dependencies. However, we also want to
# ensure we're using specific git versions from things further down the tree.

# To use local checkout: bundle config local.$GEMNAME /path/to/checkout

# Specify refs to pin the git. Local checkouts will use the branch
source "http://rubygems.org" do
    gem "ruote", :git => "https://github.com/MeeGoIntegration/ruote.git", :branch => "mint-master", :ref => "86fe481a5"
    gem "ruote-amqp", :git => "https://github.com/MeeGoIntegration/ruote-amqp.git", :branch => "master"
    gem "ruote-kit", :git => "https://github.com/MeeGoIntegration/ruote-kit.git", :branch => "master"
    gem "amqp", :git => "https://github.com/MeeGoIntegration/amqp.git", :branch => "mer-0.9.7"
end

if ENV["BOSS_GEM"]
  source "file:///srv/boss/boss/gemrepo/" do
    gem "boss"
  end
else
  gem "boss", :git => "https://github.com/MeeGoIntegration/boss.git", :branch => "master"
end
