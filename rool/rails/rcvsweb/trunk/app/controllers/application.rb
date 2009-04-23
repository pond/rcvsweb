# RCVSweb - a Ruby On Rails wrapper around the Perl-based FreeBSD
#           version of the CVSweb and Python-based CVShistory.
#
#           See "http://www.freebsd.org/projects/cvsweb.html" and
#               "http://www.jamwt.com/CVSHistory/"
#
# This wrapper was created for the sole purpose of embedding CVSweb
# output into a Rails-provided layout. This layout is shared between
# different Rails applications on one host. Using the wrapper means
# that it is not necessary to create a derived copy of the layout
# expressed in a form that CVSweb understands - instead, the layout
# can be used directly.
#
# Later extensions to the application gave it the ability to wrap
# CVShistory output too.

class ApplicationController < ActionController::Base

  # Hub single sign-on support.

  require 'hub_sso_lib'
  include HubSsoLib::Core
  before_filter :hubssolib_beforehand
  after_filter :hubssolib_afterwards

  # Turn of session management.

  session :off

  # The root URL action.
  #
  def index
    redirect_to url_for(:controller => 'rcvsweb', :action => 'run')
  end

private

  # Pass the fully qualified pathname of the script that is to be
  # executed and a path prefix from routing (e.g. "/view").

  def capture_script_output(script_location, extra_prefix)
    # Get the request URI in a way that works for FCGI and regular
    # CGI, at least for LightTPD. Strip off the PATH_PREFIX (location
    # of the Rails application) if present.

    uri = @request.env['REQUEST_URI'].dup # NOT a full URI
    uri.slice!(PATH_PREFIX + '/')

    # Split off the query string section, if there is one.

    (path_info, query) = uri.split('?')

    path_info = URI.decode(path_info) unless path_info.nil?
    query     = URI.decode(query)     unless query.nil?

    # The CGI script expects certain variables to be set up in a
    # certain way. "Slow" CGI does this but FastCGI does not because
    # the script executes under a different process environment
    # entirely, without the benefit of server-set variables. We must
    # therefore emulate the required environment by setting system
    # variables before executing the CVSweb script.

    command = ''
    needed  = %w(
                  HTTP_USER_AGENT HTTP_ACCEPT_ENCODING
                  MOD_PERL        PATH_INFO
                  SCRIPT_NAME     SCRIPT_FILENAME
                  QUERY_STRING    SERVER_PROTOCOL
                  SERVER_PORT     SERVER_NAME
                )

    needed.each do |key|

      # Override certain items where we know we want a particular
      # result, else use a server-set value if there is one.

      case key
        when 'SCRIPT_NAME'
          value = PATH_PREFIX + extra_prefix
        when 'SCRIPT_FILENAME'
          value = "#{RAILS_ROOT}/public/dispatch.cgi"
        when 'PATH_INFO'
          value = path_info || ''
          value = '/' + value unless (value[0] == '/')
          value = value[extra_prefix.length..-1] if (value[0..(extra_prefix.length - 1)] == extra_prefix)
        when 'QUERY_STRING'
          value = query
        else
          value = @request.env[key] || ''
      end

      # Add the variable initialisation statement to the command string.

      command += "#{key}=\"#{value}\" "

    end # From needed.each

    # Add the CVSweb command to the command string and execute it.
    # Return the output of the command.

    command += "#{script_location}"
    return `#{command}`
  end

  # Parse script output - pass the raw output data from the script and a
  # filename to use in the event that the output isn't of a recognised type
  # and has to be sent raw to the client.

  def parse_script_output(output, filename)
    # The Views expect to use the @output instance variable, so we operate
    # on that from the beginning.

    @output = output

    # The command should have included HTTP headers; split the two.

    pos     = @output.index("\r\n\r\n")
    short   = true unless pos
    pos     = @output.index("\n\n") unless pos
    headstr = @output.slice!(0..pos + (short ? 1 : 3)) if pos
    headers = {}

    if (headstr)

      # There are indeed some headers. Create a hash from them.

      headstr.split(short ? "\n" : "\r\n").each do |str|
        pos = str.index(':')
        headers[str.slice!(0..pos - 1).strip.downcase] = str[1..-1].strip if (pos > 1)
      end

      # If we find a Status header with a 300-series code, check for a
      # Location header too. If found, redirect to that location.

      if (headers['status'])
        code = headers['status'].to_i

        if (code >= 300 and code < 400 and headers['location'])
          redirect_to headers['location']
          return
        end
      end

      # For a content type of 'text/html', render within a View. Otherwise
      # send the data directly without a surrounding template.

      if ([ 'text/html', 'text/x-html' ].include? headers['content-type'])

        # Almost there - extract a title if we can, and chop off the header
        # and footer (HTML prologue and epilogue) to attempt to produce
        # valid (X)HTML. The version of CVSweb in use at the time of writing
        # always writes body and title container tags in lower case which
        # helps save a bit of effort.

        title_tag = @output.slice(/<title.*\/title>/)
        title_tag.gsub!(/<title.*?>/, '')
        @title = title_tag.gsub(/<\/title>/, '') || 'CVS Repository'

        # Chop everything from the front of the output string up to the end
        # of the opening body tag, inclusive.

        body_tag = @output.slice(/<body.*?>/)
        body_pos = @output.index('<body')

        if (body_pos && body_tag && body_tag.length > 0)
          @output.slice!(0..body_pos + body_tag.length - 1)
        end

        # Chop off anything after the closing body tag too.

        body_pos = @output.index('</body')
        @output.slice!(body_pos..-1) if body_pos

        # Render the default layout to send the template-based output.

        render :layout => 'default'

      else

        # Apparently, not HTML; send the data directly.

        type = headers['content-type'] || 'application/octet-stream'
        send_data @output,
                  :type        => type,
                  :disposition => 'inline'
      end

    else

      # CVSweb output had no HTTP header - this is unexpected. We don't
      # understand its output so just send this to the browser as a
      # stream of binary data.

      send_data @output,
                :filename => filename,
                :type     => 'application/octet-stream'
    end
  end
end
