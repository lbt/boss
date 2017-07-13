source "http://rubygems.org" do
#  gem "ruote-amqp", :git => "git://github.com/kennethkalmer/ruote-amqp.git", :branch => "master"
#  gem "ruote-kit", :git => "git://github.com/kennethkalmer/ruote-kit.git", :branch => "master"
#  gem "ruote", :git => "git://github.com/MeeGoIntegration/ruote.git", :ref => "86fe481a5"


  gem "rspec", :require => "spec" 
  gem "inifile"
  gem "yajl-ruby", ">=1.3.0"
  gem "amqp"
end
# That's it for our strict dependencies. However, we also want to
# ensure we're using specific git versions from things further down the tree.

# To use local checkout: bundle config local.$GEMNAME

# bundle config local.amqp $PATH_TO_SRC/ruby-amqp
#gem "amqp", :git => "git://github.com/MeeGoIntegration/amqp.git", :branch => "mer-0.9.7"

# bundle config local.ruote /maemo/devel/BOSS/src/ruby-ruote
# bundle config local.ruote-amqp /mer/mer/devel/mer-mint/boss-bundle/ruby-ruote-amqp
source "http://rubygems.org" do
  if ENV["BOSS_RUOTE_SRC"]
    gem "ruote", :path => ENV["BOSS_RUOTE_SRC"]
  else
    #gem "ruote", :git => "git://github.com/MeeGoIntegration/ruote.git", :ref => "86fe481a5"
    gem "ruote", :git => "git://github.com/MeeGoIntegration/ruote.git", :branch => "mint-master"
  end
  if ENV["BOSS_RUOTE_AMQP_SRC"]
    gem "ruote-amqp", :path => ENV["BOSS_RUOTE_AMQP_SRC"]
  else
    gem "ruote-amqp", :git => "git://github.com/kennethkalmer/ruote-amqp.git", :branch => "master"
  end
  if ENV["BOSS_RUOTE_KIT_SRC"]
    gem "ruote-kit", :path => ENV["BOSS_RUOTE_KIT_SRC"]
  else
    gem "ruote-kit", :git => "git://github.com/kennethkalmer/ruote-kit.git", :branch => "master"
  end
end

if ENV["BOSS_SRC"]
  gem "boss", :path => ENV["BOSS_SRC"]
else
  source "file:///srv/boss/boss/gemrepo/" do
    gem "boss"
  end
end

#bundle install --path=/srv/bossin1          
