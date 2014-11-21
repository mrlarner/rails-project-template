class ApiConstraints
  def initialize(options)
    @version = options[:version] || 1.0
    @default = options[:default]
    @vendor = options[:vendor] || Rails.application.class.parent_name.tableize.singularize
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.#{@vendor}.v#{@version}")
  end
end
