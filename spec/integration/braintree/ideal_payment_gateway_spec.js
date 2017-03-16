'use strict';

let Transaction = require('../../../lib/braintree/transaction').Transaction;
let ValidationErrorCodes = require('../../../lib/braintree/validation_error_codes').ValidationErrorCodes;

describe('IdealPaymentGateway', function () {
  describe('find', function () {
    it('finds the Ideal payment', done => {
      specHelper.generateValidIdealPaymentId(function (idealPaymentId) {
        specHelper.defaultGateway.idealPayment.find(idealPaymentId, function (err, idealPayment) {
          assert.isNull(err);

          assert.match(idealPayment.id, /^idealpayment_\w{6,}$/);
          assert.match(idealPayment.idealTransactionId, /^\d{16,}$/);
          assert.isDefined(idealPayment.currency);
          assert.isDefined(idealPayment.amount);
          assert.isDefined(idealPayment.status);
          assert.isDefined(idealPayment.orderId);
          assert.isDefined(idealPayment.issuer);
          assert(idealPayment.approvalUrl.startsWith('https://'));
          assert.isDefined(idealPayment.ibanBankAccount.accountHolderName);
          assert.isDefined(idealPayment.ibanBankAccount.bic);
          assert.isDefined(idealPayment.ibanBankAccount.maskedIban);
          assert.match(idealPayment.ibanBankAccount.ibanAccountNumberLast4, /^\d{4}$/);
          assert.isDefined(idealPayment.ibanBankAccount.ibanCountry);
          assert.isDefined(idealPayment.ibanBankAccount.description);

          done();
        });
      });
    });
  });

  describe('sale', () => {
    it('transacts on an Ideal payment ID', done => {
      specHelper.generateValidIdealPaymentId(function (idealPaymentId) {
        let transactionParams = {
          merchantAccountId: 'ideal_merchant_account',
          orderId: 'ABC123',
          amount: '100.00'
        };

        specHelper.defaultGateway.idealPayment.sale(idealPaymentId, transactionParams, function (err, response) {
          assert.isTrue(response.success);
          assert.equal(response.transaction.status, Transaction.Status.Settled);
          assert.match(response.transaction.idealPaymentDetails.idealPaymentId, /^idealpayment_\w{6,}$/);
          assert.match(response.transaction.idealPaymentDetails.idealTransactionId, /^\d{16,}$/);
          assert.isTrue(response.transaction.idealPaymentDetails.imageUrl.startsWith('https://'));
          assert.isDefined(response.transaction.idealPaymentDetails.maskedIban);
          assert.isDefined(response.transaction.idealPaymentDetails.bic);

          done();
        });
      });
    });

    it('fails on a non-complete Ideal payment', done => {
      specHelper.generateValidIdealPaymentId('3.00', function (idealPaymentId) {
        let transactionParams = {
          merchantAccountId: 'ideal_merchant_account',
          orderId: 'ABC123',
          amount: '3.00'
        };

        specHelper.defaultGateway.idealPayment.sale(idealPaymentId, transactionParams, function (err, response) {
          assert.isFalse(response.success);
          assert.equal(
            response.errors.for('transaction').on('paymentMethodNonce')[0].code,
            ValidationErrorCodes.Transaction.IdealPaymentNotComplete
          );

          done();
        });
      });
    });

    it('fails with an invalid ID', done => {
      let transactionParams = {
        merchantAccountId: 'ideal_merchant_account',
        orderId: 'ABC123',
        amount: '100.00'
      };

      specHelper.defaultGateway.idealPayment.sale('invalid payment ID', transactionParams, function (err, response) {
        assert.isFalse(response.success);

        done();
      });
    });
  });
});
