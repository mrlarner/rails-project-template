Rails.application.assets.register_engine('.slim', Slim::Template)
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
Rails.application.assets.context_class.class_eval do
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
end
