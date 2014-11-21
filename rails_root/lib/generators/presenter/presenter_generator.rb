class PresenterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
    
  def generate_decorator
    inside 'app' do
      inside 'presenters' do
        create_file "#{file_name}_presenter.rb", <<-FILE
class #{file_name.camelize}Presenter < BasePresenter

end
        FILE
      end
    end
  end
end
