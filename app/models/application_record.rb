# frozen_string_literal: true

# ApplicationRecord acts as a base class for all models in the application,
# providing shared behavior among them.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
