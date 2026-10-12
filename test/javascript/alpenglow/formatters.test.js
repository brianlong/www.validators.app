import { format_percent, format_decimal, format_number, format_stake } from '../../../app/javascript/packs/alpenglow/formatters'

describe('alpenglow formatters', () => {
  it('formats values', () => {
    expect(format_percent(21.787)).toBe('21.8%')
    expect(format_decimal(1.5)).toBe('1.50')
    expect(format_number(1234567)).toBe('1,234,567')
    expect(format_stake(1234567400000000)).toBe('1,234,567')
  })

  it('returns N/A for missing values', () => {
    [format_percent, format_decimal, format_number, format_stake].forEach((format) => {
      expect(format(null)).toBe('N/A')
      expect(format(undefined)).toBe('N/A')
    })
  })
})
