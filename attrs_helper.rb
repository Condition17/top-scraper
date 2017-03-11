module AttrsHelper
  def accessors(*attrs)
    @attributes = attrs
    attr_accessor *attrs
  end

  def attrs
    @attributes
  end
end