require 'net/http'
require 'uri'

class JsonWebToken
  def verify(token)
    puts ">>> verify #{token}"
    JWT.decode(token, nil,
               true, # Verify the signature of this token
               algorithm: 'RS256',
               iss: Rails.application.credentials.auth0[:domain],
               verify_iss: true,
               aud: Rails.application.credentials.auth0[:api_identifier],
               verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def jwks_hash
    jwks_raw = Net::HTTP.get URI("#{Rails.application.credentials.auth0[:domain]}.well-known/jwks.json")
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end

  def get_user_info(token)
    uri = URI.parse("#{Rails.application.credentials.auth0[:domain]}userinfo")
    req = Net::HTTP::Get.new(uri.to_s)
    req['Authorization'] = "Bearer #{token}"
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    user_info = JSON.parse(res.body)
    return user_info
  end

end
