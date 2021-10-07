require 'time'
require 'thread'

module IsItWorking
  HANDLER_PATH = '/is_it_working'

  autoload :Check, File.expand_path("../is_it_working/check.rb", __FILE__)
  autoload :Filter, File.expand_path("../is_it_working/filter.rb", __FILE__)
  autoload :Reporter, File.expand_path("../is_it_working/reporter.rb", __FILE__)
  autoload :Status, File.expand_path("../is_it_working/status.rb", __FILE__)
  autoload :Timer, File.expand_path("../is_it_working/timer.rb", __FILE__)

  # Predefined checks
  autoload :ActionMailerCheck, File.expand_path("../is_it_working/checks/action_mailer_check.rb", __FILE__)
  autoload :ActiveRecordCheck, File.expand_path("../is_it_working/checks/active_record_check.rb", __FILE__)
  autoload :DalliCheck, File.expand_path("../is_it_working/checks/dalli_check.rb", __FILE__)
  autoload :DirectoryCheck, File.expand_path("../is_it_working/checks/directory_check.rb", __FILE__)
  autoload :PingCheck, File.expand_path("../is_it_working/checks/ping_check.rb", __FILE__)
  autoload :UrlCheck, File.expand_path("../is_it_working/checks/url_check.rb", __FILE__)

  require 'is_it_working/handler'

  class Handler
    autoload :BasicAuth, File.expand_path("../is_it_working/handler/basic_auth.rb", __FILE__)
  end
end
