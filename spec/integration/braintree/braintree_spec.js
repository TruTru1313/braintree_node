'use strict';

let braintree = specHelper.braintree;

describe('Braintree', () =>
  describe('AuthenticationError', () =>
    it('is returned with invalid credentials', function (done) {
      let gateway = specHelper.braintree.connect({
        environment: specHelper.braintree.Environment.Development,
        merchantId: 'invalid',
        publicKey: 'invalid',
        privateKey: 'invalid'
      });

      return gateway.transaction.sale({}, function (err) {
        assert.equal(err.type, braintree.errorTypes.authenticationError);

        done();
      });
    })
  )
);
