import Vue from 'vue/dist/vue.esm'
import { shallowMount } from '@vue/test-utils'
import IndexTemplate from '../../../app/javascript/packs/commission_histories/index_template'
import { PaginationPlugin } from "bootstrap-vue";
import { BPagination } from "bootstrap-vue";
import axios from 'axios'

jest.mock('axios');

var mock_commission_changes = function(){
  axios.get.mockResolvedValue({
    data: [
      {
        commission_histories: {
          account: '123',
          name: 'customName',
          network: 'testnet'
        }
      }
    ]
  });
}


describe('index_template', ()=> {
  it('has correct params without query', ()=>{
    Vue.component('BPagination', BPagination)
    mock_commission_changes()
    const wrapper = shallowMount(IndexTemplate, {
      propsData: {
        network: 'testnet'
      },
      stubs: {BPagination: BPagination}
    })

    expect(wrapper.vm.api_url).toMatch("/api/v1/commission-changes/testnet?")
    expect(wrapper.vm.page).toBe(1)
    expect(wrapper.vm.sort_by).toMatch('created_at_desc')
    expect(wrapper.vm.account_name).toBe(undefined)
  })

  it('has correct params with query', ()=>{
    Vue.component('BPagination', BPagination)
    mock_commission_changes()
    const wrapper = shallowMount(IndexTemplate, {
      propsData: {
        query: 'abc',
        network: 'testnet'
      },
      stubs: {BPagination: BPagination}
    })

    expect(wrapper.vm.api_url).toMatch("/api/v1/commission-changes/testnet?query=abc&")
    expect(wrapper.vm.page).toBe(1)
    expect(wrapper.vm.sort_by).toMatch('created_at_desc')
    expect(wrapper.vm.account_name).toBe('abc')
  })
})
