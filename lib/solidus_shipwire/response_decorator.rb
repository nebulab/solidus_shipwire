module SolidusShipwire::Response
  def resource
    body['resource'].with_indifferent_access
  end

  def to_sku_id_hashmap
    Hash[resource[:items].map do |v|
      [v[:resource][:sku], v[:resource][:id]]
    end]
  end

  def next?
    resource[:next].present?
  end

  end
end

Shipwire::Response.prepend SolidusShipwire::Response
