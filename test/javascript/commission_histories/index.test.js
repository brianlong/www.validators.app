import Vue from 'vue/dist/vue.esm'
import { shallowMount } from '@vue/test-utils'
import IndexTemplate from '../../../app/javascript/packs/commission_histories/index_template'
import { BPagination } from "bootstrap-vue";
import axios from 'axios';
import store from "../../../app/javascript/packs/stores/main_store.js";

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
      store,
      stubs: {BPagination: BPagination}
    })

    expect(wrapper.vm.api_url).toMatch("/api/v1/commission-changes/mainnet?")
    expect(wrapper.vm.page).toBe(1)
    expect(wrapper.vm.sort_by).toMatch('created_at_desc')
    expect(wrapper.vm.account_name).toBe(undefined)
  })

  it('has correct params with query', ()=>{
    Vue.component('BPagination', BPagination)
    mock_commission_changes()
    const wrapper = shallowMount(IndexTemplate, {
      store,
      propsData: {
        query: 'abc'
      },
      stubs: {BPagination: BPagination}
    })

    expect(wrapper.vm.api_url).toMatch("/api/v1/commission-changes/mainnet?query=abc&")
    expect(wrapper.vm.page).toBe(1)
    expect(wrapper.vm.sort_by).toMatch('created_at_desc')
    expect(wrapper.vm.account_name).toBe('abc')
  })
})
