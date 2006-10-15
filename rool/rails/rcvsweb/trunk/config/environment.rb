# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '1.1.5'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Location of application relative to document root in terms of
# URLs (i.e. according to the web server configuration, not the
# filesystem location) and location in the filesystem, rather than
# according to the Web server, of the CVSweb and CVShistory scripts.

PATH_PREFIX         = '/rails/rcvsweb'
CVSWEB_LOCATION     = '/home/adh/perl/cvsweb/cvsweb.cgi'
CVSHISTORY_LOCATION = '/home/adh/python/cvshistory/cvshistory.cgi'

Rails::Initializer.run do |config|
  # We don't run in the document root, so images etc. must come from
  # a non-root location too. Hijack the 'asset host' facility to get
  # helper-based links pointing in the right place.

  config.action_controller.asset_host = PATH_PREFIX

  # Skip frameworks that are not used.

  config.frameworks -= [ :action_web_service, :action_mailer, :active_record ]

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug).

  config.log_level = :warn
end

# Allow multiple Rails applications by giving the session cookie a
# unique prefix. In this application the ApplicationController class
# turns sessions off (at the time of writing, 22-Aug-2006) anyway,
# but in future sessions may be used again in which case the line
# below will be important.

ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_key] = 'rcvswebapp_session_id'
