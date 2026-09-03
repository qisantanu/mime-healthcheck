source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7', '>= 6.1.7.10'
# Use jdbcsqlite3 as the database for Active Record
# gem 'activerecord-jdbcsqlite3-adapter'
gem 'activerecord-oracle_enhanced-adapter', '6.1.6'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
# gem 'sass-rails', '>= 6'  # removed — not needed (no SCSS files) and native C ext fails on JRuby
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'warbler', git: 'https://github.com/qinvent/warbler.git'
  # Pin jruby-jars to 9.3.10.0 so the WAR embeds a Java-8-compatible JRuby
  # (JRuby 10.x requires Java 21; our WebLogic 12c runs Java 8).
  gem 'jruby-jars', '9.3.10.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
