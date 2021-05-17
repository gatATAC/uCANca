source 'https://rubygems.org'

gem 'roo'

gem 'rails', '3.2.15'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'nokogiri', '< 1.12'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'less-rails-bootstrap'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'twitter-bootstrap-rails'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
#gem 'debugger'
#gem 'byebug'
gem "hobo", "= 2.0.1"
# Hobo has a lot of assets.   Stop cluttering the log in development mode.
gem "quiet_assets", :group => :development
# Hobo's version of will_paginate is required.
gem "will_paginate", :git => "git://github.com/Hobo/will_paginate.git"
gem "hobo_bootstrap", "2.0.1"
gem "hobo_jquery_ui", "2.0.1"
gem "hobo_bootstrap_ui", "2.0.1"
gem "jquery-ui-themes", "~> 0.0.4"

gem 'acts_as_list'

gem "dyi"        # add gem of DYI
gem "dyi_rails"  # add gem of DYI for Rails


group :production do
#  gem 'pg'
  gem 'sqlite3'
end
group :development, :test do
  gem 'sqlite3'
end

gem 'thin'
#gem 'tiny_mce'

gem 'builder'
