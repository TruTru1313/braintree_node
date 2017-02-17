import '../../spec_helper';
import { SignatureService } from '../../../lib/braintree/signature_service';

describe("SignatureService", () =>
  it("signs the data with the given key and hash", function() {
    let hashFunction = (key, data) => `${data}-hashed-with-${key}`;
    let signatureService = new SignatureService("my-key", hashFunction);
    let signed = signatureService.sign("my-data");
    return assert.equal(signed, "my-data-hashed-with-my-key|my-data");
  })
);
