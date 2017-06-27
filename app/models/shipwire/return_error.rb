module Shipwire
  class ReturnError
    attr_reader :key, :message

    ERROR_MESSAGES = {
      shipwire_unprocessed:          "Only orders that are \"processed\" and not \"cancelled\" can be returned",
      shipwire_already_reported:     "You have already reported this issue.",
      shipwire_connection_failed:    "Unable to connect to Shipwire",
      shipwire_timeout:              "Shipwire connection timeout",
      shipwire_something_went_wrong: "Something went wrong"
    }.freeze

    def initialize(string)
      @string = string
      @key = retrieve_key_from_string

      # To override default messages provided from Shipwire just create a I18n
      # key with the following scope:
      #
      # shipwire:
      #   returns:
      #     errors:
      #       shipwire_unprocessed: "My custom message"
      @message = I18n.t(@key, scope: [:shipwire, :returns, :errors], default: string)
    end

    def self.build_from_response(response)
      validation_errors = response.validation_errors.map { |e| e['message'] }
      error_summary     = response.error_summary
      shipwire_errors   = (validation_errors + [error_summary]).compact

      shipwire_errors.map { |error| new(error) }
    end

    private

    attr_reader :string

    def retrieve_key_from_string
      # There are multiple messages that contains this string, sometimes...
      return :shipwire_something_went_wrong if string.include?("Something went wrong")

      ERROR_MESSAGES.key(string) || :generic_error
    end
  end
end
