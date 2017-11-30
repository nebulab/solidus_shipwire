module SolidusShipwire
  module ApiDecorator
    def request(method, path, body: {}, params: {})
      Shipwire::Request.send(method: method, path: full_path(path), body: body, params: params)
    end

    private

    def api_version
      'v3'
    end

    def full_path(path)
      "#{api_version}/#{path}"
    end

    Shipwire::Api.prepend self
  end
end
