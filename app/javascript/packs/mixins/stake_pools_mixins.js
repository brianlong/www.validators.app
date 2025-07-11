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

import AeroSmall from 'aero-logo.svg'
import AeroLarge from 'aero.png'

import VaultSmall from 'vault-logo.png'
import VaultLarge from 'vault.png'

import XshinSmall from 'xshin-logo.png'
import XshinLarge from 'xshin.png'

import JagSmall from 'jagpool-logo.png'
import JagLarge from 'jagpool.png'

import DynosolSmall from 'dynosol-logo.png'
import DynosolLarge from 'dynosol.png'

import DefinitySmall from 'definsol-logo.png'
import DefinityLarge from 'definsol.png'

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
  },
  "aero": {
    "small_logo": AeroSmall,
    "large_logo": AeroLarge
  },
  "vault": {
    "small_logo": VaultSmall,
    "large_logo": VaultLarge
  },
  "xshin": {
    "small_logo": XshinSmall,
    "large_logo": XshinLarge
  },
  "jagpool": {
    "small_logo": JagSmall,
    "large_logo": JagLarge
  },
  "dynosol": {
    "small_logo": DynosolSmall,
    "large_logo": DynosolLarge
  },
  "definity": {
    "small_logo": DefinitySmall,
    "large_logo": DefinityLarge
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
