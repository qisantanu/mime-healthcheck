require 'jars/version'

class HealthController < ActionController::Base
  def show
    ActiveRecord::Base.connection.execute('SELECT * from TBL_MAP')
    render plain: "OK jruby=#{JRUBY_VERSION} jar-dependencies=#{Jars::VERSION} db=#{ActiveRecord::Base.connection.adapter_name}"
  end
end
