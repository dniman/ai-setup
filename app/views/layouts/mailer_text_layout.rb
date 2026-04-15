class Views::Layouts::MailerTextLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def view_template
    yield
  end
end
