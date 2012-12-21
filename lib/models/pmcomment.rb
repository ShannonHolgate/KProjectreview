require 'mongoid'

class Pmcomment
  include Mongoid::Document
  field pmc_id: Integer
  field re_id: Integer
  field ra_id: Integer
  field desc: String
end
