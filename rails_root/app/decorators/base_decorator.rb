class BaseDecorator < SimpleDelegator
  def initialize(model)
    @model = model
    super
  end
end

# class LargeBurger < BaseDecorator
#   def cost
#     @burger.cost + 15
#   end
# end

# burder = Burger.new
# large_burger = LargeBurger.new(burger)

# burger.cost = 10
# large_burger.cost = 25
