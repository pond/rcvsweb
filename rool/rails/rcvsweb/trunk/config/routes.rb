ActionController::Routing::Routes.draw do |map|

  # Route all URLs through the 'rcvsweb' controller's 'run' action
  map.connect PATH_PREFIX + '/*url', :controller => 'rcvsweb', :action => 'run'

end
