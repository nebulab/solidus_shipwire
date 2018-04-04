module SolidusShipwire
  module ResponseDecorator
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

    def virtual_kit?
      resource[:classification] == "virtualKit"
    end

    Shipwire::Response.prepend self
  end
end
