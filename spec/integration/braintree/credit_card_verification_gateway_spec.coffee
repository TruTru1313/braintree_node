require('../../spec_helper')
braintree = specHelper.braintree

describe "CreditCardVerificationGateway", ->
  describe "find", ->
    it "finds a verification", (done) ->
      customerParams =
        creditCard:
          cardholderName: "John Smith"
          number: '4000111111111115'
          expirationDate: '05/2014'
          options:
            verifyCard: true

      specHelper.defaultGateway.customer.create customerParams, (err, response) ->
        specHelper.defaultGateway.creditCardVerification.find response.verification.id, (err, verification) ->
          assert.isNull(err)
          assert.equal(verification.creditCard.cardholderName, 'John Smith')
          
          done()

    it "handles not finding a verification", (done) ->
      specHelper.defaultGateway.creditCardVerification.find 'nonexistent_verification', (err, verification) ->
        assert.equal(err.type, braintree.errorTypes.notFoundError)

        done()

    it "handles whitespace ids", (done) ->
      specHelper.defaultGateway.creditCardVerification.find ' ', (err, verification) ->
        assert.equal(err.type, braintree.errorTypes.notFoundError)

        done()


# vows
#   .describe('CreditCardVerificationGateway')
#   .addBatch
#       'when using a card with card type indicators':
#         topic: ->
#           callback = @callback
#           name = specHelper.randomId() + ' Smith'
#           specHelper.defaultGateway.customer.create({
#             creditCard:
#               cardholderName: name,
#               number: CreditCardNumbers.CardTypeIndicators.Unknown,
#               expirationDate: '05/12',
#               options:
#                 verifyCard: true
#             }, (err, response) ->
#               specHelper.defaultGateway.creditCardVerification.search((search) ->
#                 search.creditCardCardholderName().is(name)
#               , (err, response) ->
#                 response.first((err, result) ->
#                   callback(err,
#                     verification: result
#                     name: name
#                   )
#                 )
#               )
#             )
#           undefined
#         'card details card type indicator should be prepaid': (err, result) ->
#           assert.isNull(err)
#           assert.equal(result.verification.creditCard.cardholderName, result.name)
#           assert.equal(result.verification.creditCard.prepaid, CreditCard.Prepaid.Unknown)
#           assert.equal(result.verification.creditCard.durbinRegulated, CreditCard.DurbinRegulated.Unknown)
#           assert.equal(result.verification.creditCard.commercial, CreditCard.Commercial.Unknown)
#           assert.equal(result.verification.creditCard.healthcare, CreditCard.Healthcare.Unknown)
#           assert.equal(result.verification.creditCard.debit, CreditCard.Debit.Unknown)
#           assert.equal(result.verification.creditCard.payroll, CreditCard.Payroll.Unknown)
# 
#   .export(module)
