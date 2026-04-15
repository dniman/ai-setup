class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout -> { Views::Layouts::MailerLayout }
end
