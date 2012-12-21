require 'mongoid'

class Employee
  include Mongoid::Document
  field :emp_id, type: Integer
  field :username, type: String
  field :password, type: String
  field :f_name, type: String
  field :s_name, type: String
  field :role, type: String
  field :pm_flag, type: Boolean
  field :cm_flag, type: Boolean
  field :cm_id, type: Integer
end
