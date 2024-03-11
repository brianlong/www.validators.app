import Vue from 'vue';

import BlazeStakeSmall from 'blazestake-logo.png'
import BlazeStakeLarge from 'blazestake.png'

import DAOPoolSmall from 'daopool-logo.png'
import DAOPoolLarge from 'daopool.png'

import JitoSmall from 'jito-logo.svg'
import JitoLarge from 'jito.png'

import JpoolSmall from 'jpool-logo.svg'
import JpoolLarge from 'jpool.png'

import LidoSmall from 'lido-logo.svg'
import LidoLarge from 'lido.png'

import MarinadeSmall from 'marinade-logo.svg'
import MarinadeLarge from 'marinade.png'

import SoceanSmall from 'socean-logo.svg'
import SoceanLarge from 'socean.png'

import ZippyStakeSmall from 'zippystake-logo.svg'
import ZippyStakeLarge from 'zippystake.png'

import EdgevanaStakeSmall from 'edgevana-logo.svg'
import EdgevanaStakeLarge from 'edgevana.png'

const logos = {
  "blazestake": {
    "small_logo": BlazeStakeSmall,
    "large_logo": BlazeStakeLarge,
  },
  "daopool": {
    "small_logo": DAOPoolSmall,
    "large_logo": DAOPoolLarge,
  },
  "jito": {
    "small_logo": JitoSmall,
    "large_logo": JitoLarge,
  },
  "jpool": {
    "small_logo": JpoolSmall,
    "large_logo": JpoolLarge,
  },
  "lido": {
    "small_logo": LidoSmall,
    "large_logo": LidoLarge,
  },
  "marinade": {
    "small_logo": MarinadeSmall,
    "large_logo": MarinadeLarge,
  },
  "socean": {
    "small_logo": SoceanSmall,
    "large_logo": SoceanLarge,
  },
  "zippystake": {
    "small_logo": ZippyStakeSmall,
    "large_logo": ZippyStakeLarge
  },
  "edgevana": {
    "small_logo": EdgevanaStakeSmall,
    "large_logo": EdgevanaStakeLarge
  }
}

Vue.mixin({
  methods: {
    stake_pool_small_logo(stake_pool) {
      return logos[stake_pool.toLowerCase()]["small_logo"];
    },
    stake_pool_large_logo(stake_pool) {
      return logos[stake_pool.toLowerCase()]["large_logo"];
    },
  }
});
