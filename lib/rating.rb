require 'mongoid'

class Rating
  include Mongoid::Document
  field ra_id: Integer
  field name: String
  field desc: String
end
