# frozen_string_literal: true

# ApplicationMailer acts as a base class for all Mailers in the application,
# providing shared behavior among them.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
