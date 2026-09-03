Warbler::Config.new do |config|
  config.jar_extension = 'war'
  config.webinf_files += FileList['config/weblogic.xml']
  config.webxml.rails.env = ENV['RAILS_ENV'] || 'production'
  config.webxml.public.root = '/mima-healthcheck'
end