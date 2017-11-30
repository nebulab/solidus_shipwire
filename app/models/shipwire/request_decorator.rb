module SolidusShipwire
  module RequestDecorator
    private

    def full_path
      "/api/#{@path}"
    end

    Shipwire::Request.prepend self
  end
end
