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
          if(sign.detached.verify(message, resp, ctx.public_key.toBytes())){
            //create user
          }
        })
      }
    },
    components: { 'wallet-multi-button': WalletMultiButton }
  }
</script>
