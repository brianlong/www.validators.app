import Vue from 'vue';

import BlazeStakeSmall from 'blazestake-logo.png'
import BlazeStakeLarge from 'blazestake.png'

import DAOPoolSmall from 'daopool-logo.png'
import DAOPoolLarge from 'daopool.png'

import EversolSmall from 'eversol-logo.svg'
import EversolLarge from 'eversol.png'

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

const logos = {
  "blazestake": {
    "smallLogo": BlazeStakeSmall,
    "largeLogo": BlazeStakeLarge,
  },
  "daopool": {
    "smallLogo": DAOPoolSmall,
    "largeLogo": DAOPoolLarge,
  },
  "eversol": {
    "smallLogo": EversolSmall,
    "largeLogo": EversolLarge,
  },
  "jito": {
    "smallLogo": JitoSmall,
    "largeLogo": JitoLarge,
  },
  "jpool": {
    "smallLogo": JpoolSmall,
    "largeLogo": JpoolLarge,
  },
  "lido": {
    "smallLogo": LidoSmall,
    "largeLogo": LidoLarge,
  },
  "marinade": {
    "smallLogo": MarinadeSmall,
    "largeLogo": MarinadeLarge,
  },
  "socean": {
    "smallLogo": SoceanSmall,
    "largeLogo": SoceanLarge,
  },
}

Vue.mixin({
  methods: {
    stakePoolSmallLogo(stake_pool) {
      return logos[stake_pool.toLowerCase()]["smallLogo"];
    },
    stakePoolLargeLogo(stake_pool) {
      return logos[stake_pool.toLowerCase()]["largeLogo"];
    },
  }
});
