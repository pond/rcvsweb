module ApplicationHelper

  # Turn the Hub and Rails flash data into a simple series of H2 entries,
  # with Hub data first, Rails flash data next. A container DIV will hold
  # zero or more H2 entries:
  #
  #   <div class="flash">
  #     <h2 class="flash foo">Bar</h2>
  #   </div>
  #
  # ...where "foo" is the flash key, e.g. "alert", "notice" and "Bar" is
  # the flash value, made HTML-safe.
  #
  def apphelp_flash
    data = hubssolib_flash_data()
    html = ""

    return tag.div( :class => 'flash' ) do
      data[ 'hub' ].each do | key, value |
        concat( tag.h2( value, :class => "flash #{ key }" ) )
      end

      data[ 'standard' ].each do | key, value |
        concat( tag.h2( value, :class => "flash #{ key }" ) )
      end
    end
  end

  # Run simple_format on the given input text, then scan for "Ticket #xxx" strings
  # and replace them with Collaboa ticket display links.
  #
  def format_with_collaboa_links(text)
    simple_format(text).gsub(/([Tt]icket *#*)([0-9]*)/, '<a href="/tracker/tickets/\2">\1\2</a>').html_safe()
  end

  # Return a sort of "wrappable <pre>" block of text as a paragraph with individual
  # lines wrapped by <code>...</code>, and leading non-breaking spaces for any
  # indenting spaces at the start of lines (but not thereafter).
  #
  def apphelp_wrappable_pre(text)
    return tag.p() do
      text.each_line do | line |
        line = h( line )
        line.sub!(/^\s*/) do | match |
          '&nbsp;' * match.length
        end

        concat( tag.code() { line.strip.html_safe } )
        concat( tag.br() )
      end
    end
  end
end
