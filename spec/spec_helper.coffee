try
  require('source-map-support').install()
catch err

http = require('http')
{Util} = require('../lib/braintree/util')
querystring = require('../vendor/querystring.node.js.511d6a2/querystring')
chai = require("chai")
{Buffer} = require('buffer')
xml2js = require('xml2js')

GLOBAL.assert = chai.assert

GLOBAL.assert.isEmptyArray = (array) ->
  assert.isArray(array)
  assert.equal(array.length, 0)

GLOBAL.inspect = (object) ->
  console.dir(object)

braintree = require('./../lib/braintree.js')

defaultConfig = {
  environment: braintree.Environment.Development
  merchantId: 'integration_merchant_id'
  publicKey: 'integration_public_key'
  privateKey: 'integration_private_key'
}

defaultGateway = braintree.connect(defaultConfig)

multiplyString = (string, times) ->
  (new Array(times+1)).join(string)

plans = {
  trialless: { id: 'integration_trialless_plan', price: '12.34' }
  addonDiscountPlan: {
    id: 'integration_plan_with_add_ons_and_discounts',
    price: '9.99'
  }
}

addOns = {
  increase10: 'increase_10'
  increase20: 'increase_20'
}

escrowTransaction = (transactionId, callback) ->
  defaultGateway.http.put(
    "/transactions/#{transactionId}/escrow",
    null,
    callback
  )

makePastDue = (subscription, callback) ->
  defaultGateway.http.put(
    "/subscriptions/#{subscription.id}/make_past_due?days_past_due=1",
    null,
    callback
  )

settleTransaction = (transactionId, callback) ->
  defaultGateway.http.put(
    "/transactions/#{transactionId}/settle",
    null,
    callback
  )

simulateTrFormPost = (url, trData, inputFormData, callback) ->
  headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Host': 'localhost'
  }
  formData = Util.convertObjectKeysToUnderscores(inputFormData)
  formData.tr_data = trData
  requestBody = querystring.stringify(formData)
  headers['Content-Length'] = requestBody.length.toString()

  options = {
    port: specHelper.defaultGateway.config.environment.port
    host: specHelper.defaultGateway.config.environment.server
    method: 'POST'
    headers: headers
    path: url
  }

  if specHelper.defaultGateway.config.environment.ssl
    request = https.request(options, ->)
  else
    request = http.request(options, ->)

  request.on('response', (response) ->
    callback(null, response.headers.location.split('?', 2)[1])
  )

  request.write(requestBody)
  request.end()

dateToMdy = (date) ->
  year = date.getFullYear().toString()
  month = (date.getMonth() + 1).toString()
  day = date.getDate().toString()
  if month.length == 1
    month = "0" + month
  if day.length == 1
    day = "0" + day
  formattedDate = year + '-' + month + '-' + day
  return formattedDate

nowInEastern = ->
  now = new Date
  eastern = now.getTime() - (5*60*60*1000)
  return new Date(eastern)

randomId = ->
  Math.floor(Math.random() * Math.pow(36,8)).toString(36)

doesNotInclude = (array, value) ->
  assert.isTrue(array.indexOf(value) is -1)

class ClientApiHttp
  timeout: 60000

  constructor: (@config) ->
    @parser = new xml2js.Parser
      explicitRoot: true

  get: (url, callback) ->
    @request('GET', url, null, callback)

  checkHttpStatus: (status) ->
    switch status.toString()
      when '200', '201', '422' then null
      else status.toString()

  request: (method, url, body, callback) ->
    client = http

    options = {
      host: @config.environment.server,
      port: @config.environment.port,
      method: method,
      path: url,
      headers: {
        'X-ApiVersion': @config.apiVersion,
        'Accept': 'application/xml',
        'Content-Type': 'application/json',
        'User-Agent': 'Braintree Node ' + braintree.version
      }
    }

    if body
      requestBody = JSON.stringify(Util.convertObjectKeysToUnderscores(body))
      options.headers['Content-Length'] = Buffer.byteLength(requestBody).toString()

    theRequest = client.request(options, (response) =>
      body = ''
      response.on('data', (responseBody) -> body += responseBody )

      response.on('end', =>
        error = @checkHttpStatus(response.statusCode)
        return callback(error, null) if error
        if body isnt ' '
          @parser.parseString body, (err, result) ->
            callback(null, Util.convertNodeToObject(result))
        else
          callback(null, null)
      )

      response.on('error', (err) ->
        return callback("Unexpected response error: #{err}", null)
      )
    )

    theRequest.setTimeout(@timeout, ->
      return callback("timeout", null)
    )

    theRequest.on('error', (err) ->
      return callback("Unexpected request error: #{err}", null)
    )

    theRequest.write(requestBody) if body
    theRequest.end()

GLOBAL.specHelper = {
  addOns: addOns
  braintree: braintree
  dateToMdy: dateToMdy
  defaultConfig: defaultConfig
  defaultGateway: defaultGateway
  doesNotInclude: doesNotInclude
  escrowTransaction: escrowTransaction
  makePastDue: makePastDue
  multiplyString: multiplyString
  nowInEastern: nowInEastern
  plans: plans
  randomId: randomId
  settleTransaction: settleTransaction
  simulateTrFormPost: simulateTrFormPost
  defaultMerchantAccountId: "sandbox_credit_card"
  nonDefaultMerchantAccountId: "sandbox_credit_card_non_default"
  nonDefaultSubMerchantAccountId: "sandbox_sub_merchant_account"
  clientApiHttp: ClientApiHttp
}
