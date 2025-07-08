// Description: This script fetches and decodes policies from the Yellowstone program on Solana.

require('dotenv/config');
const fs = require('fs');
const solanaWeb3 = require('@solana/web3.js');
const {
  decodeAccount,
  fixDecoderSize,
  getStructDecoder,
  getU8Decoder,
  getAddressDecoder,
  getBytesDecoder
} = require('@solana/kit');
const {
  getTokenMetadata,
  TOKEN_2022_PROGRAM_ID,
  getMint
} = require('@solana/spl-token');

const config = {
  solanaUrl: process.env.SOLANA_URL,
  yellowstoneProgramId: process.env.YELLOWSTONE_PROGRAM_ID
};

const connection = new solanaWeb3.Connection(config.solanaUrl, "confirmed");
var timestamp = process.argv.slice(2);
var yellowstoneProgramId = new solanaWeb3.PublicKey(config.yellowstoneProgramId);
var address_decoder = getAddressDecoder();

function getPolicyWithMintDecoder() {
  return getStructDecoder([
    ['kind', getU8Decoder()],
    ['strategy', getU8Decoder()],
    ['nonce', getU8Decoder()],
    ['mint', getAddressDecoder()],
    ['identitiesLen', fixDecoderSize(getU8Decoder(), 4)],
    ['identities', getBytesDecoder(), { size: 1 }],
  ]);
}

function getPolicyWithoutMintDecoder() {
  return getStructDecoder([
    ['kind', getU8Decoder()],
    ['strategy', getU8Decoder()],
    ['nonce', getU8Decoder()],
    ['identitiesLen', fixDecoderSize(getU8Decoder(), 4)],
    ['identities', getBytesDecoder(), { size: 1 }],
  ]);
}

function decodePolicy(encodedAccount, mint = true) {
  if (mint) {
    return decodeAccount(
      encodedAccount,
      getPolicyWithMintDecoder()
    );
  } else {
    return decodeAccount(
      encodedAccount,
      getPolicyWithoutMintDecoder()
    );
  }
}

async function getPolicyTokenMetadata(mintAddress) {
  try {
    const mintPubkey = new solanaWeb3.PublicKey(mintAddress);
    const metadata = await getTokenMetadata(connection, mintPubkey);
    return metadata;
  } catch (e) {
    return null;
  }
}

connection.getParsedProgramAccounts(yellowstoneProgramId, {
  encoding: "jsonParsed"
}).then(async policies => {
  let decoded_policies = []

  for (const policy of policies) {
    let decoded = decodePolicy(policy.account);

    // get token metadata for mint
    let token_metadata = null;
    if (decoded.data.mint) {
      token_metadata = await getPolicyTokenMetadata(decoded.data.mint);
      if (token_metadata === null) {
        decoded = decodePolicy(policy.account, false);
      }
    }

    let tmp_identities = [];
    for (let i = 0; i < decoded.data.identities.length; i+=32) {
      if (i + 32 > decoded.data.identities.length) {
        break; // Prevent out of bounds access
      }
      const identity = decoded.data.identities.slice(i, i + 32);
      const address = address_decoder.decode(identity);
      tmp_identities.push(address);
    }
    decoded.data.identities = tmp_identities;

    const result = {
      pubkey: policy.pubkey,
      data: decoded.data,
      executable: policy.account.executable,
      owner: policy.account.owner.toBase58(),
      lamports: policy.account.lamports,
      rent_epoch: policy.account.rentEpoch,
      token_metadata: token_metadata
    };
    decoded_policies.push(result);
  }

  let decoded_policies_json = JSON.stringify(decoded_policies, null, 2);
  fs.writeFileSync('./storage/policies/decoded_policies_' + timestamp + '.json', decoded_policies_json);
}).catch(err => {
  console.error("Error fetching filtered accounts:", err);
});
