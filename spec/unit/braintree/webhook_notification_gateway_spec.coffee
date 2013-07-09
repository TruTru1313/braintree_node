require('../../spec_helper')

{ValidationErrorCodes} = require('../../../lib/braintree/validation_error_codes')
{WebhookNotification} = require('../../../lib/braintree/webhook_notification')
errorTypes = require('../../../lib/braintree/error_types')

describe "WebhookNotificationGateway", ->
  describe "verify", ->
    it "creates a verification string for the challenge", ->
      result = specHelper.defaultGateway.webhookNotification.verify("verification_token")

      assert.equal(result, "integration_public_key|c9f15b74b0d98635cd182c51e2703cffa83388c3")

  describe "sampleNotification", ->
    it "returns a parsable signature and payload", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.SubscriptionWentPastDue,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse signature, payload, (err, webhookNotification) ->
        assert.equal(webhookNotification.kind, WebhookNotification.Kind.SubscriptionWentPastDue)
        assert.equal(webhookNotification.subscription.id, "my_id")
        assert.ok(webhookNotification.timestamp?)
        done()

    it "returns an errback with InvalidSignatureError when signature is invalid", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.SubscriptionWentPastDue,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse "bad_signature", payload, (err, webhookNotification) ->
        assert.equal(err.type, errorTypes.invalidSignatureError)
        done()

    it "returns an errback with InvalidSignatureError when the public key is modified", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.SubscriptionWentPastDue,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse "bad#{signature}", payload, (err, webhookNotification) ->
        assert.equal(err.type, errorTypes.invalidSignatureError)
        done()

    it "returns an errback with InvalidSignatureError when the signature is modified", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.SubscriptionWentPastDue,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse "#{signature}bad", payload, (err, webhookNotification) ->
        assert.equal(err.type, errorTypes.invalidSignatureError)
        done()

    it "returns a parsable signature and payload for merchant account approvals", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.MerchantAccountApproved,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse signature, payload, (err, webhookNotification) ->
        assert.equal(webhookNotification.kind, WebhookNotification.Kind.MerchantAccountApproved)
        assert.equal(webhookNotification.merchantAccount.id, "my_id")
        assert.ok(webhookNotification.timestamp?)
        done()

    it "returns a parsable signature and payload for merchant account declines", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.MerchantAccountDeclined,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse signature, payload, (err, webhookNotification) ->
        assert.equal(webhookNotification.kind, WebhookNotification.Kind.MerchantAccountDeclined)
        assert.equal(webhookNotification.merchantAccount.id, "my_id")
        assert.equal(webhookNotification.errors.for("merchantAccount").on("base")[0].code, ValidationErrorCodes.MerchantAccount.ApplicantDetails.DeclinedOFAC)
        assert.equal(webhookNotification.message, "Credit score is too low")
        assert.ok(webhookNotification.timestamp?)
        done()

    it "returns a parsable signature and payload for disbursed transaction", (done) ->
      {signature, payload} = specHelper.defaultGateway.webhookTesting.sampleNotification(
        WebhookNotification.Kind.TransactionDisbursed,
        "my_id"
      )

      specHelper.defaultGateway.webhookNotification.parse signature, payload, (err, webhookNotification) ->
        assert.equal(webhookNotification.kind, WebhookNotification.Kind.TransactionDisbursed)
        assert.equal(webhookNotification.transaction.id, "my_id")
        assert.equal(webhookNotification.transaction.amount, '100')
        assert.ok(webhookNotification.transaction.disbursementDetails.disbursementDate?)
        done()
