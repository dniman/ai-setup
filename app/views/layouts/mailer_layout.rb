class Views::Layouts::MailerLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype
    html do
      head do
        raw safe('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">')
        style { "/* Email styles need to be inline */" }
      end
      body(&block)
    end
  end
end
