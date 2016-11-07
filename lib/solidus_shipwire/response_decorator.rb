module SolidusShipwire::Response
  private

  def parse_error_summary_from(body)
    if (400..599).cover?(body['status']) && body.key?('message')
      body['message']
    else
      body.fetch('error', nil).presence
    end
  end
end

Shipwire::Response.prepend SolidusShipwire::Response
