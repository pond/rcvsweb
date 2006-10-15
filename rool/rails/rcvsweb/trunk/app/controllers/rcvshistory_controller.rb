class RcvshistoryController < ApplicationController

  # All "/history/*" routes lead to the 'run' method, which invokes CVShistory
  # based on the request URL and embeds the result in a View. Since the
  # mechanism for embedding script output is common to CVShistory and CVSweb,
  # the core code for this is in the application controller.

  def run
    parse_script_output(capture_script_output(CVSHISTORY_LOCATION, '/history'), 'history_data.dat')
  end
end
