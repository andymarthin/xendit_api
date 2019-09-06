# frozen_string_literal: true

require 'faraday'

module FaradayMiddleware
  class RaiseHttpException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        case response[:status].to_i
        when 400
          raise XenditApi::BadRequest.new error_message_400(response), raw_body(response)
        when 401
          raise XenditApi::Unauthorized.new error_message_400(response), raw_body(response)
        when 403
          raise XenditApi::Forbidden.new error_message_400(response), raw_body(response)
        when 404
          raise XenditApi::NotFound.new error_message_400(response), raw_body(response)
        when 500
          raise XenditApi::InternalServerError.new error_message_500(response, 'Something is technically wrong.'), raw_body(response)
        when 502
          raise XenditApi::BadGateway.new error_message_500(response, 'The server returned an invalid or incomplete response.'), raw_body(response)
        when 504
          raise XenditApi::GatewayTimeout.new error_message_500(response, '504 Gateway Time-out'), raw_body(response)
        end
      end
    end

    def initialize(app)
      super app
      @parser = nil
    end

    private

    def error_message_400(response)
      "#{response[:method].to_s.upcase} #{response[:url]}: #{response[:status]}#{error_body(response[:body])}"
    end

    def error_body(body)
      # body gets passed as a string, not sure if it is passed as something else from other spots?
      if !body.nil? && !body.empty? && body.is_a?(String)
        # removed multi_json thanks to wesnolte's commit
        body = ::JSON.parse(body)
      end

      if body.nil?
        nil
      elsif body['meta'] && body['meta']['error_message'] && !body['meta']['error_message'].empty?
        ": #{body['meta']['error_message']}"
      elsif body['error_message'] && !body['error_message'].empty?
        ": #{body['error_type']}: #{body['error_message']}"
      elsif body['error_code'] && !body['error_code'].empty?
        ": #{body['error_code']}: #{body['message']}"
      end
    end

    def error_message_500(response, body = nil)
      "#{response[:method].to_s.upcase} #{response[:url]}: #{[response[:status].to_s + ':', body].compact.join(' ')}"
    end

    def raw_body(response)
      ::JSON.parse(response.body)
    end
  end
end
