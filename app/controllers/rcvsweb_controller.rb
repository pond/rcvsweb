class RcvswebController < ApplicationController

  # All "/view/*" routes lead to the 'run' method, which invokes CVSweb
  # based on the request URL and embeds the result in a View. Since the
  # mechanism for embedding script output is common to CVSweb and
  # CVShistory, the core code for this is in the application controller.

  def run
    parse_script_output(capture_script_output(CVSWEB_LOCATION, '/view'), 'view_data.dat')
  end
end
