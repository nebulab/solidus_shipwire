class SolidusShipwire::ShipwireObject
  attr_accessor :id, :object, :attrs

  def initialize(id, object, attrs)
    @id = id
    @object = object
    @attrs = attrs.with_indifferent_access
  end
end
