class SolidusShipwire::ShipwireObject
  attr_accessor :id, :object, :attrs

  def initialize(id, object, attrs)
    @id = id
    @object = object
    @attrs = attrs.with_indifferent_access
  end

  def classification
    @attrs[:classification]
  end

  def virtual_kit?
    classification == 'virtualKit'
  end

  def base_product?
    classification == 'baseProduct'
  end

  def marketing_insert?
    classification == 'marketingInsert'
  end

  def kit?
    classification == 'kit'
  end
end
