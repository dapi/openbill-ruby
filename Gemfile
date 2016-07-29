source 'https://rubygems.org'

def darwin?
  RbConfig::CONFIG['host_os'] =~ /darwin/
end

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

# Specify your gem's dependencies in openbill.gemspec
gemspec

gem 'rails', '~> 4.0'
gem 'sequel'
gem 'money'
gem 'money-rails', github: 'RubyMoney/money-rails'

group :test, :development do
  gem 'database_cleaner'
  gem 'pry-nav'
  gem 'pry'
  # gem 'breakman'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'factory_girl_rails'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  # gem 'ruby_gntp'
  gem 'growl', require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'spring'

  gem 'minitest'
  gem 'minitest-around'

  gem 'listen'
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-bundler'
  gem 'guard-ctags-bundler'
  gem 'guard-rubocop'

  # Открывает письмо в браузере сразу после отправки
  # gem 'launchy'
end
