class RcvswebController < ApplicationController

  # All routes lead to the 'run' method, which invokes CVSweb based
  # on the request URL and embeds the result in a View.

  def run

    # Get the request URI in a way that works for FCGI and regular
    # CGI, at least for LightTPD. Strip off the PATH_PREFIX (location
    # of the Rails application) if present.

    uri = @request.env['REQUEST_URI'].dup
    uri.slice!(PATH_PREFIX + '/')

    # Split off the query string section, if there is one.

    (path_info, query) = uri.split('?')

    # Under CGI, the command we run executes from the Web server's
    # CGI context. That's running the Rails dispatcher, but all the
    # same, it sets up sufficient environment details to make the
    # script work OK. Under FCGI the command runs under the FCGI
    # process environment, which is nothing like a normal CGI setup.
    # Things don't work. To get around this, take the Web server's
    # specified environment details and compile a large command that
    # sets all of the environment variables before running CVSweb.

    command = ''
    accept  = [ 'HTTP_USER_AGENT', 'HTTP_ACCEPT_ENCODING', 'MOD_PERL' ]

    @request.env.each do |key, value|

      # Set up environment variables

      case key
        when 'SCRIPT_NAME'
          value = PATH_PREFIX
        when 'SCRIPT_FILENAME'
          value = "#{RAILS_ROOT}/public/dispatch.cgi"
        when 'PATH_INFO'
          value = path_info || ''
          value = '/' + value unless (value[0] == '/')
        when 'QUERY_STRING'
          value = query
        else
          next unless accept.include?(key)
      end

      command += "#{key}=\"#{value}\" "

    end # From @request.env.each

    command += "#{CVSWEB_LOCATION}"
    @output  = `#{command}`

    # The command should have included HTTP headers; split the two.

    pos     = @output.index("\r\n\r\n")
    headstr = @output.slice!(0..pos + 3) if pos
    headers = {}

    if (headstr)

      # There are indeed some headers. Create a hash from them.

      headstr.downcase.split("\r\n").each do |str|
        pos = str.index(':')
        headers[str.slice!(0..pos - 1).strip] = str[1..-1].strip if (pos > 1)
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
                :filename => 'rcvsweb.dat',
                :type     => 'application/octet-stream'
    end
  end
end
