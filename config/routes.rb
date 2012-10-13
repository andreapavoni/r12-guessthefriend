Guesswho::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'

  root to: 'site#index'
  get '/play', to: 'site#play'

  get '/g/del/:id', to: 'site#eliminate', as: :eliminate
  get '/g/trash',   to: 'site#restart',   as: :restart
  get '/g/next',    to: 'site#hint',      as: :next_hint
end
