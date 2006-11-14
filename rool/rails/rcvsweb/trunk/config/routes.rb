ActionController::Routing::Routes.draw do |map|

  # Root
  map.connect PATH_PREFIX + '/', :controller => 'application', :action => 'index'

  # CVSweb: Route through the 'rcvsweb' controller's 'run' action
  map.connect PATH_PREFIX + '/view/*url', :controller => 'rcvsweb', :action => 'run'

  # CVShistory: Route through the 'rcvshistory' controller's 'run' action
  map.connect PATH_PREFIX + '/history/*url', :controller => 'rcvshistory', :action => 'run'

  # Synthesised revision list and cvslog2web wrapping
  map.connect PATH_PREFIX + '/revisions/',        :controller => 'revisions', :action => 'list'
  map.connect PATH_PREFIX + '/revisions/:action', :controller => 'revisions'
end
