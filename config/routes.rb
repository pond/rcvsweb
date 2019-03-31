Rails.application.routes.draw do

  root to: 'application#index'

  get    'view/(:url)', to:     'rcvsweb#run'
  get 'history/(:url)', to: 'rcvshistory#run'

  get 'revisions',         to: 'revisions#list'
  get 'revisions/:action', controller: 'revisions'

end
