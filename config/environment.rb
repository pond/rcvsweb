# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Rails Gem Version
RAILS_GEM_VERSION = '1.2.6' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Location of application relative to document root in terms of
# URLs (i.e. according to the web server configuration, not the
# filesystem location) and location in the filesystem, rather than
# according to the Web server, of the CVSweb and CVShistory scripts.
# Next up is the filesystem location of CVSLog2Web output and the
# path to use for URLs for CVShistory - the bit up to and including
# the ".cgi", before the query string is appended, excluding the
# host. The host is taken from ENV['SERVER_ADDR']. If the request
# uses port DEVEL_HTTP_PORT, it is switched to DEVEL_HTTPS_PORT for
# an HTTPS request. If the port is already DEVEL_HTTPS_PORT it
# is left alone, again for an HTTPS request. Otherwise, the port
# is reset to 443.
#
# Since HTTPS requests may require a certificate chain, you can
# configure this in SSL_CERT_CHAIN; this should point to a ".crt"
# bundle (as a full path) giving the chain of trust for your SSL
# certificate at the target site. You may choose to provide this
# via an environment variable if you wish. Use 'nil' or an empty
# string if you want no such chain specifying.

PATH_PREFIX         = '/viewer'
CVSWEB_LOCATION     = '/home/rool/devel/perl/cvsweb/cvsweb.cgi'
CVSHISTORY_LOCATION = '/home/rool/devel/python/cvshistory/cvshistory.cgi'
CVSLOG2WEB_OUTPUT   = '/home/rool/devel/python/cvslog2web/public'
CVSLOG2WEB_PREFIX   = '/python/cvshistory/cvshistory.cgi'
DEVEL_HTTP_PORT     = '25080'
DEVEL_HTTPS_PORT    = '25081'
SSL_CERT_CHAIN      = ENV[ 'SSL_CERT_CHAIN' ]

Rails::Initializer.run do |config|
  # Skip frameworks that are not used.

#  config.frameworks -= [ :action_web_service, :action_mailer, :active_record ]
  config.frameworks -= [ :action_web_service, :action_mailer ]

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
