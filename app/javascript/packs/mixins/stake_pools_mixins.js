import Vue from 'vue';

import BlazeStake from 'blazestake-logo.png'
import DAOPool from 'daopool-logo.png'
import Eversol from 'eversol-logo.svg'
import Jito from 'jito-logo.svg'
import Jpool from 'jpool-logo.svg'
import Lido from 'lido-logo.svg'
import Marinade from 'marinade-logo.svg'
import Socean from 'socean-logo.svg'

const logos = {
  "BlazeStake": BlazeStake,
  "DAOPool": DAOPool,
  "Eversol": Eversol,
  "Jito": Jito,
  "Jpool": Jpool,
  "Lido": Lido,
  "Marinade": Marinade,
  "Socean": Socean,
}

Vue.mixin({
  methods: {
    stakePoolSmallLogo(stake_pool) {
      return logos[stake_pool];
    },
  }
});
