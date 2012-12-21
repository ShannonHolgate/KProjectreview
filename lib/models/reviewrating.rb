require 'mongoid'

class Reviewrating
  include Mongoid::Document
  field :re_id, type: Integer
  field :ra_id, type: Integer
  field :rating, type: Integer
  field :rev_id, type: Integer
end