module ApplicationHelper
  # - present(@post) do |post|
  # %h2= post.title
  # %p= post.author
  def present(model)
    klass = "#{model.class}Presenter".contantize
    presenter = klass.new(model, self)
    yield(presenter) if block_given?
  end
end
