import { shallowMount } from '@vue/test-utils'
import Index from '../../../app/javascript/packs/commission_histories/index.js'

describe('props', ()=> {
  it('has correct query', ()=>{
    const wrapper = shallowMount(Index, {

    })

    expect(wrapper.find('table').exists()).toBeTruthy()
  })
})