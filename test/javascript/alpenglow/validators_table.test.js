import { shallowMount } from '@vue/test-utils'
import ValidatorsTable from '../../../app/javascript/packs/alpenglow/validators_table'
import axios from 'axios'
import store from "../../../app/javascript/packs/stores/main_store.js"

jest.mock('axios')

const validators_response = {
  data: {
    epoch: 224,
    total_count: 30,
    validators: [
      {
        validator_name: 'Block Logic',
        validator_account: 'IdentityA',
        vote_account: 'VoteAccountAddressA',
        stake: 1234567000000000,
        rank: 3,
        notar_votes: 9,
        notar_reward_slots: 10,
        notar_participation: 90.0,
        fast_inclusion: 75.0,
        slow_inclusion: 50.0,
        skip_votes: 5,
        divergent_skip_votes: 2,
        leader_slots: 8,
        leader_fast_percent: 25.0,
        average_final_lag: 1.5,
        client: 'JitoLabs',
        version: '4.3.0'
      },
      {
        validator_name: null,
        validator_account: 'IdentityB',
        vote_account: 'VoteAccountAddressB',
        stake: null,
        rank: null,
        notar_participation: null,
        skip_votes: 0,
        divergent_skip_votes: 0,
        leader_slots: 0,
        client: null,
        version: null
      }
    ]
  }
}

const flush = async (wrapper) => {
  await wrapper.vm.$nextTick()
  await wrapper.vm.$nextTick()
}

const mount_table = (propsData = { epoch: 224, refreshed_at: 1 }) => {
  store.getters = { network: 'alpenglow-community' }
  return shallowMount(ValidatorsTable, { store, propsData, stubs: ['b-pagination'] })
}

describe('validators_table', () => {
  beforeEach(() => {
    axios.get.mockReset()
    axios.get.mockResolvedValue(validators_response)
  })

  it('fetches validators for the epoch with default sorting', () => {
    mount_table()

    expect(axios.get).toHaveBeenCalledWith(
      '/api/v1/alpenglow-validator-stats/alpenglow-community?sort_by=notar_participation&direction=desc&page=1&per=25&epoch=224'
    )
  })

  it('renders validator metrics', async () => {
    const wrapper = mount_table()
    await flush(wrapper)

    const text = wrapper.text()
    expect(text).toContain('Block Logic')
    expect(text).toContain('1,234,567')
    expect(text).toContain('90.0%')
    expect(text).toContain('9 / 10')
    expect(text).toContain('75.0%')
    expect(text).toContain('1.50')
    expect(text).toContain('JitoLabs')
    expect(text).toContain('VoteAc…essB')
    expect(wrapper.find('a[href="/validators/IdentityA?network=alpenglow-community"]').exists()).toBe(true)
  })

  it('toggles sort direction and changes sort column', async () => {
    const wrapper = mount_table()
    await flush(wrapper)

    wrapper.vm.sort('notar_participation')
    expect(wrapper.vm.direction).toBe('asc')
    expect(axios.get).toHaveBeenLastCalledWith(expect.stringContaining('sort_by=notar_participation&direction=asc'))

    wrapper.vm.sort('divergent_skip_votes')
    expect(wrapper.vm.sort_by).toBe('divergent_skip_votes')
    expect(wrapper.vm.direction).toBe('desc')
    expect(axios.get).toHaveBeenLastCalledWith(expect.stringContaining('sort_by=divergent_skip_votes&direction=desc'))
  })

  it('reloads when parent refreshes or epoch changes', async () => {
    const wrapper = mount_table()
    await flush(wrapper)
    expect(axios.get).toHaveBeenCalledTimes(1)

    await wrapper.setProps({ refreshed_at: 2 })
    expect(axios.get).toHaveBeenCalledTimes(2)

    await wrapper.setProps({ epoch: 223 })
    expect(axios.get).toHaveBeenCalledTimes(3)
    expect(axios.get).toHaveBeenLastCalledWith(expect.stringContaining('&epoch=223'))
  })

  it('shows empty state', async () => {
    axios.get.mockResolvedValue({ data: { epoch: null, total_count: 0, validators: [] } })
    const wrapper = mount_table()
    await flush(wrapper)

    expect(wrapper.text()).toContain('No validator statistics for this epoch yet.')
  })
})
