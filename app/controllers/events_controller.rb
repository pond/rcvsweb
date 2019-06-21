require 'json'

class EventsController < ApplicationController

  @@last_file_datetime = nil
  @@event_data         = nil

  def index
    last_file_datetime = File.mtime(GITLAB_JSON_LOCATION)

    if (@@last_file_datetime.nil? || last_file_datetime > @@last_file_datetime)
      @@event_data         = JSON.parse(File.read(GITLAB_JSON_LOCATION))
      @@last_file_datetime = last_file_datetime
    end

    @title  = "Events"
    @events = @@event_data
  end
end
