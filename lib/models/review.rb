require 'mongoid'

class Review
  include Mongoid::Document
  field :re_id, type: Integer
  field :pr_id, type: Integer
  field :emp_id, type: Integer
  field :pm_id, type: Integer
  field :rev_start, type: Date
  field :rev_end, type: Date
end
