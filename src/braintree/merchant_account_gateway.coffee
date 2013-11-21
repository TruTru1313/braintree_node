{Gateway} = require('./gateway')
{MerchantAccount} = require('./merchant_account')

class MerchantAccountGateway extends Gateway
  constructor: (@gateway) ->

  create: (attributes, callback) ->
    @gateway.http.post('/merchant_accounts/create_via_api', {merchantAccount: attributes}, @responseHandler(callback))

  update: (id, attributes, callback) ->
    @gateway.http.put("/merchant_accounts/#{id}/update_via_api", {merchantAccount: attributes}, @responseHandler(callback))

  responseHandler: (callback) ->
    @createResponseHandler("merchantAccount", MerchantAccount, callback)

exports.MerchantAccountGateway = MerchantAccountGateway
