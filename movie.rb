require './attrs_helper'

class Movie
  extend AttrsHelper
  accessors :name, :picture, :year, :rating, :description, :writer, :actor, :director

  def to_json
    data = {}
    Movie.attrs.each { |attr| data[attr] = send(attr.to_s) }
    data
  end
end
