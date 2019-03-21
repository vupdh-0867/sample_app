Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "static_pages/help"
    get "static_pages/about"
    get "static_pages/contact"
    root "static_pages#home"
  end
end
