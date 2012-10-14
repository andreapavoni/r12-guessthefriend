Guesswho::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'

  root to: 'site#index'
  get '/play', to: 'site#play'
  get '/leaderboard', to: 'site#leaderboard'

  get '/g/make',    to: 'site#stalk',     as: :make_game
  get '/g/del',     to: 'site#eliminate', as: :eliminate
  get '/g/guess',   to: 'site#guess',     as: :guess
  get '/g/abandon', to: 'site#abandon',   as: :abandon
  get '/g/restart', to: 'site#restart',   as: :restart
  get '/g/next',    to: 'site#hint',      as: :next_hint
  get '/g/epicfail',to: 'site#reveal',    as: :reveal
  put '/g/ftw',     to: 'site#won',       as: :won
end
