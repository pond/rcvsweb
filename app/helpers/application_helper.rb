module ApplicationHelper

  # Run simple_format on the given input text, then scan for "Ticket #xxx" strings
  # and replace them with Collaboa ticket display links.
  #
  def format_with_collaboa_links(text)
    simple_format(text).gsub(/([Tt]icket *#*)([0-9]*)/, '<a href="/tracker/tickets/\2">\1\2</a>')
  end
end
