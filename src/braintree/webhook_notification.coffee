{AttributeSetter} = require('./attribute_setter')
{MerchantAccount} = require('./merchant_account')
{Subscription} = require('./subscription')
{ValidationErrorsCollection} = require('./validation_errors_collection')

class WebhookNotification extends AttributeSetter
  @Kind =
    SubscriptionCanceled: "subscription_canceled"
    SubscriptionChargedSuccessfully: "subscription_charged_successfully"
    SubscriptionChargedUnsuccessfully: "subscription_charged_unsuccessfully"
    SubscriptionExpired: "subscription_expired"
    SubscriptionTrialEnded: "subscription_trial_ended"
    SubscriptionWentActive: "subscription_went_active"
    SubscriptionWentPastDue: "subscription_went_past_due"
    MerchantAccountApproved: "merchant_account_approved"
    MerchantAccountDeclined: "merchant_account_declined"

  constructor: (attributes) ->
    super attributes

    if attributes.subject.apiErrorResponse?
      wrapper_node = attributes.subject.apiErrorResponse
    else
      wrapper_node = attributes.subject

    if wrapper_node.subscription?
      @subscription = new Subscription(wrapper_node.subscription)

    if wrapper_node.merchantAccount?
      @merchantAccount = new MerchantAccount(wrapper_node.merchantAccount)

    if wrapper_node.errors?
      @errors = new ValidationErrorsCollection(wrapper_node.errors)
      @message = wrapper_node.message

exports.WebhookNotification = WebhookNotification
