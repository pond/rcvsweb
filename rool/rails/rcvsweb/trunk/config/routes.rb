ActionController::Routing::Routes.draw do |map|

  map.root '/', :controller => 'application', :action => 'index'

  # CVSweb: Route through the 'rcvsweb' controller's 'run' action
  map.connect '/view/*url', :controller => 'rcvsweb', :action => 'run'

  # CVShistory: Route through the 'rcvshistory' controller's 'run' action
  map.connect '/history/*url', :controller => 'rcvshistory', :action => 'run'

  # Synthesised revision list and cvslog2web wrapping
  map.connect '/revisions/',        :controller => 'revisions', :action => 'list'
  map.connect '/revisions/:action', :controller => 'revisions'
end
