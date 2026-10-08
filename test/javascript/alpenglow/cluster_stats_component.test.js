import { shallowMount } from '@vue/test-utils'
import ClusterStatsComponent from '../../../app/javascript/packs/alpenglow/cluster_stats_component_template'
import axios from 'axios'
import store from "../../../app/javascript/packs/stores/main_store.js"

jest.mock('axios')

const stats_response = {
  data: {
    epochs: [222, 221],
    cluster_stats: {
      epoch: 222,
      leaders: 69,
      leader_slots: 806,
      finalized_blocks: 638,
      fast_finalized: 139,
      slow_finalized: 499,
      fast_percent: 21.787,
      slow_percent: 78.213,
      average_final_lag: 1.5,
      final_cert_percent: 93.14,
      updated_at: new Date().toISOString(),
      clients: [
        { client: 'JitoLabs', leaders: 45, leader_slots: 400, leader_slots_percent: 49.63, versions: ['4.3.0', '4.3.0-rc.1'] }
      ]
    }
  }
}

const mount_component = () => {
  store.getters = { network: 'alpenglow-community' }
  return shallowMount(ClusterStatsComponent, { store })
}

describe('cluster_stats_component', () => {
  beforeEach(() => {
    jest.useFakeTimers()
    axios.get.mockReset()
    axios.get.mockResolvedValue(stats_response)
  })

  afterEach(() => {
    jest.useRealTimers()
  })

  it('fetches stats for the current network', () => {
    const wrapper = mount_component()

    expect(wrapper.vm.api_url).toBe('/api/v1/alpenglow-cluster-stats/alpenglow-community')
    expect(axios.get).toHaveBeenCalledWith('/api/v1/alpenglow-cluster-stats/alpenglow-community')
  })

  it('renders cluster stats and clients', async () => {
    const wrapper = mount_component()
    await wrapper.vm.$nextTick()
    await wrapper.vm.$nextTick()

    expect(wrapper.text()).toContain('21.8%')
    expect(wrapper.text()).toContain('1.50')
    expect(wrapper.text()).toContain('93.1%')
    expect(wrapper.text()).toContain('806')
    expect(wrapper.text()).toContain('JitoLabs')
    expect(wrapper.text()).toContain('4.3.0, 4.3.0-rc.1')
  })

  it('requests older epoch and goes back to latest without epoch param', async () => {
    const wrapper = mount_component()
    await wrapper.vm.$nextTick()

    wrapper.vm.select_epoch(221)
    expect(axios.get).toHaveBeenLastCalledWith('/api/v1/alpenglow-cluster-stats/alpenglow-community?epoch=221')

    wrapper.vm.select_epoch(222)
    expect(axios.get).toHaveBeenLastCalledWith('/api/v1/alpenglow-cluster-stats/alpenglow-community')
  })

  it('refreshes stats every minute', () => {
    mount_component()
    expect(axios.get).toHaveBeenCalledTimes(1)

    jest.advanceTimersByTime(60 * 1000)
    expect(axios.get).toHaveBeenCalledTimes(2)
  })

  it('shows empty state when there are no stats', async () => {
    axios.get.mockResolvedValue({ data: { epochs: [], cluster_stats: null } })
    const wrapper = mount_component()
    await wrapper.vm.$nextTick()
    await wrapper.vm.$nextTick()

    expect(wrapper.text()).toContain('No Alpenglow statistics are available for alpenglow-community yet.')
  })

  it('formats missing values as N/A', () => {
    const wrapper = mount_component()

    expect(wrapper.vm.format_percent(null)).toBe('N/A')
    expect(wrapper.vm.format_decimal(undefined)).toBe('N/A')
    expect(wrapper.vm.format_number(1234567)).toBe('1,234,567')
  })
})
