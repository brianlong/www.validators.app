<template>
  <div class="col-12">
    <wallet-multi-button ref="walletConnector" :wallets="wallets" auto-connect dark/>
    <button @click.prevent="sign_up()">sign up</button>
  </div>
</template>

<script>
  import { WalletMultiButton } from 'solana-wallets-vue-2';
  import 'solana-wallets-vue-2/styles.css'
  import { PhantomWalletAdapter } from '@solana/wallet-adapter-wallets'
  import { sign } from 'tweetnacl';
  import bs58 from 'bs58';

  export default {
    data(){
      return {
        wallets: [
          new PhantomWalletAdapter()
        ],
        public_key: null
      }
    },
    mounted(){
      this.$watch(
        () => {
            return this.$refs.walletConnector.walletStore?.publicKey
        },
        (val) => {
          console.log(val.toBuffer())
          console.log(val.toJSON())
          console.log(val.toString())
          console.log(val.toBase58())
          this.public_key = val
        }
      )
    },
    methods: {
      async sign_up()  {
        var ctx = this
        const message = new TextEncoder().encode('Hello, world!');
        console.log(message)

        await this.$refs.walletConnector.walletStore.signAllTransactions(message)
        .then(function(resp){
          console.log("response: " + bs58.encode(resp))
          console.log("response: " + ctx.strToUtf16Bytes(resp))
          if(sign.detached.verify(message, resp, ctx.public_key.toBytes())){
            //create user
          }
        })
      },
      strToUtf16Bytes(str) {
        const bytes = [];
        console.log("parsing string: " + str)
        for (var ii = 0; ii < str.length; ii++) {
          const code = str.charCodeAt(ii); // x00-xFFFF
          bytes.push(code & 255, code >> 8); // low, high
        }
        return bytes;
      }
    },
    components: { 'wallet-multi-button': WalletMultiButton }
  }
</script>
