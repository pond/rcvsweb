# RCVSweb - a Ruby On Rails wrapper around the Perl-based FreeBSD
#           version of the CVSweb application.
#
#           See "http://www.freebsd.org/projects/cvsweb.html".
#
# This wrapper was created for the sole purpose of embedding CVSweb
# output into a Rails-provided layout. This layout is shared between
# different Rails applications on one host. Using the wrapper means
# that it is not necessary to create a derived copy of the layout
# expressed in a form that CVSweb understands - instead, the layout
# can be used directly.

class ApplicationController < ActionController::Base
end
