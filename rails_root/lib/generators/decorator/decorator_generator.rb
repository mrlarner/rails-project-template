class DecoratorGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)  
  # argument :decorator, type: :string
    
  def generate_decorator
    inside 'app' do
      inside 'decorators' do
        create_file "#{file_name}.rb", <<-FILE
class #{file_name.camelize} < BaseDecorator

end
        FILE
      end
    end
  end
end
