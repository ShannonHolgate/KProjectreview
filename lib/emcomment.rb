require 'mongoid'

class Emcomment
  include Mongoid::Document
  field emc_id: Integer
  field re_id: Integer
  field ra_id: Integer
  field desc: String
end
