# frozen_string_literal: true

# This module was created based on the following URL https://github.com/xojan0120/auth_firebase_test/blob/master/app/helpers/firebase_helper.rb

require 'jwt'
require 'yaml'
require 'net/http'

module FirebaseAuth
  # rubocop:disable all
  CONFIG = YAML.load_file(Rails.root.join('config/firebase.yml'))

  module Auth
    ALGORITHM       = 'RS256'
    ISSUER_BASE_URL = 'https://securetoken.google.com/'
    CLIENT_CERT_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    class << self
      def verify_id_token(token)
        raise 'Id token must be a String' unless token.is_a?(String)

        full_decoded_token = decode_jwt(token)

        errors = validate(full_decoded_token)
        raise errors.join(' / ') unless errors.empty?

        public_key = fetch_public_keys[full_decoded_token[:header]['kid']]
        unless public_key
          raise <<-ERROR.squish
            Firebase ID token has "kid" claim which does not correspond to a known public key.
            Most likely the ID token is expired, so get a fresh token from your client app and try again.
          ERROR
        end

        certificate = OpenSSL::X509::Certificate.new(public_key)
        decoded_token = decode_jwt(token, certificate.public_key, true, { algorithm: ALGORITHM, verify_iat: false })

        { 'uid' => decoded_token[:payload]['sub'], 'decoded_token' => decoded_token }
      end

      private

      def decode_jwt(token, key = nil, verify = false, options = {})
        begin
          decoded_token = JWT.decode(token, key, verify, options)
        rescue JWT::ExpiredSignature
          raise 'Firebase ID token has expired. Get a fresh token from your client app and try again.'
        rescue StandardError => e
          raise "Firebase ID token has invalid signature. #{e.message}"
        end

        { payload: decoded_token[0], header: decoded_token[1] }
      end

      def fetch_public_keys
        uri = URI.parse(CLIENT_CERT_URL)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        res = https.start do
          https.get(uri.request_uri)
        end
        data = JSON.parse(res.body)
        if data['error']
          if data['error_description']
            msg = %(Error fetching public keys for Google certs: #{data['error']} (#{res['error_description']}))
          end
          raise msg
        end

        data
      end

      def validate(json)
        errors     = []
        project_id = FirebaseAuth::CONFIG['project_info']['project_id']
        payload    = json[:payload]
        header     = json[:header]
        issuer     = ISSUER_BASE_URL + project_id

        errors << %(Firebase ID token has no "kid" claim.) unless header['kid']
        unless header['alg']  == ALGORITHM  then errors << %(Firebase ID token has incorrect algorithm. Expected "#{ALGORITHM}" but got "#{header['alg']}".) end
        unless payload['aud'] == project_id then errors << %(Firebase ID token has incorrect aud (audience) claim. Expected "#{project_id}" but got "#{payload['aud']}".) end
        unless payload['iss'] == issuer     then errors << %(Firebase ID token has incorrect "iss" (issuer) claim. Expected "#{issuer}" but got "#{payload['iss']}".) end
        errors << %(Firebase ID token has no "sub" (subject) claim.) unless payload['sub'].is_a?(String)
        errors << %(Firebase ID token has an empty string "sub" (subject) claim.) if payload['sub'].empty?
        if     payload['sub'].size > 128 then errors << %(Firebase ID token has "sub" (subject) claim longer than 128 characters.) end

        errors
      end
    end
  end
  # rubocop:enable all
end
