// Description: This script fetches and decodes policies from the Yellowstone program on Solana.

require('dotenv').config();

config = {
  solanaUrl: process.env.SOLANA_URL,
  yellowstoneProgramId: process.env.YELLOWSTONE_PROGRAM_ID
};
var fs = require('fs');

const solanaWeb3 = require("@solana/web3.js");
const {
  decodeAccount,
  fixDecoderSize,
  getStructDecoder,
  getU8Decoder,
  getAddressDecoder,
  getBytesDecoder
} = require('@solana/kit');

const connection = new solanaWeb3.Connection(config.solanaUrl, "confirmed");
var timestamp = process.argv.slice(2);
var yellowstoneProgramId = new solanaWeb3.PublicKey(config.yellowstoneProgramId);
var address_decoder = getAddressDecoder();

function getPolicyDecoder() {
  return getStructDecoder([
    ['kind', getU8Decoder()],
    ['strategy', getU8Decoder()],
    ['nonce', getU8Decoder()],
    ['identitiesLen', fixDecoderSize(getU8Decoder(), 4)],
    ['identities', getBytesDecoder(), { size: 1 }],
  ]);
}

function decodePolicy(encodedAccount) {
  return decodeAccount(
    encodedAccount,
    getPolicyDecoder()
  );
}

connection.getParsedProgramAccounts(yellowstoneProgramId, {
  encoding: "jsonParsed"
}).then(policies => {
  let decoded_policies = []

  policies.forEach(policy => {
    const decoded = decodePolicy(policy.account);
    let tmp_identities = []
    for (let i = 0; i < decoded.data.identities.length; i+=32) {
      if (i + 32 > decoded.data.identities.length) {
        break; // Prevent out of bounds access
      }
      const identity = decoded.data.identities.slice(i, i + 32);
      const address = address_decoder.decode(identity);
      tmp_identities.push(address);
    }
    decoded.data.identities = tmp_identities;
    decoded_policies.push(decoded);
  });

  let decoded_policies_json = JSON.stringify(decoded_policies, null, 2);
  fs.writeFileSync('./storage/policies/decoded_policies_' + timestamp + '.json', decoded_policies_json);
}).catch(err => {
  console.error("Error fetching filtered accounts:", err);
});
