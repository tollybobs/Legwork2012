Legwork2012::Application.routes.draw do
  root :to => 'desktop#index'
  match 'tweetyeah' => 'external_data#tweetyeah'
  match '*pages' => 'desktop#index'
end
