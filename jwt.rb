# Inspited by:...
# https://medium.com/xcblog/generating-jwt-tokens-for-app-store-connect-api-2b2693812a35
# + Fixed syntax issue
# + Reading issuer and key from args (https://stackoverflow.com/a/26444165/8923019)

require "base64"
require "jwt"
require 'optparse'
require 'ostruct'

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-i', '--issuer ISSUER_ID', 'The Issuer') { |o| options.issuer = o }
  opt.on('-k', '--keyid KEY_ID', 'The Key ID') { |o| options.key_id = o }
end.parse!

raise OptionParser::MissingArgument if options.issuer.nil?
raise OptionParser::MissingArgument if options.key_id.nil?

private_key = OpenSSL::PKey.read(File.read("AuthKey_#{options.key_id}.p8"))
token = JWT.encode(
   {
    iss: options.issuer,
    exp: Time.now.to_i + 20 * 60,
    aud: "appstoreconnect-v1"
   },
   private_key,
   "ES256",
   header_fields={ kid: options.key_id }
 )
puts token
