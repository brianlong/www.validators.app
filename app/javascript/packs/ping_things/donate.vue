<template>

</template>

<script>
import {
  ACTIONS_CORS_HEADERS,
  ActionGetResponse,
  ActionPostRequest,
  ActionPostResponse,
  createPostResponse,
} from "@solana/actions"

import {
  Connection,
  LAMPORTS_PER_SOL,
  PublicKey,
  SystemProgram,
  Transaction,
} from "@solana/web3.js";

export default {
    data () {
        console.log("donate.js data()");
        return {
            api_url: api_url,
            last_5_mins: {},
            last_60_mins: {},
            pt_url: pt_url
        }
    },

    created () {

    },

    mounted: function() {

    }
}
  </script>
  