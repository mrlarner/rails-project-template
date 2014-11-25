class BasePresenter < SimpleDelegator
  def initialize(model, view)
    @model, @view = model, view
    super(@model)
  end

  def h
    @view
  end
end

# example
# class PostPresenter < BasePresenter
#   def publication_status
#     if @model.published_at?
#         h.time_ago_in_words(@model.published_at)
#     else
#       'Draft'
#     end
#     # use h to access view helpers
#     def emphatic
#       h.content_tag(:strong, "Awesome")
#     end
#   end
# end

# class PostsController < ApplicationController
#   def show
#     post = Post.find(params[:id])
#     @post = PostPresenter.new(post, view_context)
#   end
# end

# in view
# @post.published_at?
