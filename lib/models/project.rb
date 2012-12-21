require 'mongoid'

class Project
include Mongoid::Document
  field :pr_id, type: Integer
  field :name, type: String
end