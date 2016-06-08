source 'https://rubygems.org'

#BEGIN PATCH
gem 'sprockets-rails','2.3.3'
#END PATCH

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end


gem 'hobo', '= 2.2.6'
gem 'protected_attributes'
gem 'responders', '2.1.0'
# Hobo has a lot of assets.   Stop cluttering the log in development mode.
gem 'quiet_assets', group: :development
# Hobo's version of will_paginate is required.
gem 'hobo_will_paginate'
gem 'hobo_bootstrap', '2.2.6'
gem 'hobo_jquery_ui', '2.2.6'
gem 'hobo_bootstrap_ui', '2.2.6'
gem 'jquery-ui-themes', '~> 0.0.4'
gem 'hobo_clean_admin', '2.2.6'

#### BEGIN Not hobo default gems 

gem 'acts_as_list'

gem "dyi"        # add gem of DYI
gem "dyi_rails"  # add gem of DYI for Rails


group :production do
  gem 'pg'
end
group :development, :test do
  gem 'sqlite3'
end

gem 'thin'
#gem 'tiny_mce'

gem 'builder'

gem 'roo'

gem "paperclip"
gem 'hobo_paperclip', :git => "git://github.com/Hobo/hobo_paperclip.git", :branch => "master"
