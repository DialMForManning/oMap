require 'require_all'
require_all 'lib'

class Book < SQLObject
  belongs_to :reader
  belongs_to :library

  self.make_helpers!
end

class Reader < SQLObject
  belongs_to :library

  has_many :books,
    foreign_key: :reader_id

    self.make_helpers!
end

class Library < SQLObject
  has_many :readers

  has_many :books

  self.make_helpers!
end
