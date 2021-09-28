import CommissionHistoryRow from '../../../app/javascript/packs/commission_histories/commission_history_row'
import { shallowMount } from '@vue/test-utils'

describe('commission_history_row', ()=> {
  it('has correct chistory_name', ()=>{
    const wrapper = shallowMount(CommissionHistoryRow, {
      propsData: {
        chistory: {
          account: '1234abcdef1234',
          name: 'customName',
          network: 'testnet',
          commission_before: 10,
          commission_after: 20
        }
      }
    })
    expect(wrapper.vm._data.chistory_name).toMatch("customName")
  })

  it('has correct chistory_name when no name in props', ()=>{
    const wrapper = shallowMount(CommissionHistoryRow, {
      propsData: {
        chistory: {
          account: '123',
          name: null,
          network: 'testnet',
          commission_before: 10,
          commission_after: 20
        }
      }
    })
    expect(wrapper.vm._data.chistory_name).toMatch("123...123")
  })

  it('has correct descending', ()=>{
    const wrapper = shallowMount(CommissionHistoryRow, {
      propsData: {
        chistory: {
          account: '123',
          name: null,
          network: 'testnet',
          commission_before: 10,
          commission_after: 20
        }
      }
    })
    expect(wrapper.vm._data.descending).toBe(false)
  })
})
