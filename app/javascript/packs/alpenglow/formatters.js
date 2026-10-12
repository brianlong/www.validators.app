const LAMPORTS_PER_SOL = 1000000000

const is_missing = (value) => value === null || value === undefined

export const format_percent = (value) => is_missing(value) ? 'N/A' : value.toFixed(1) + '%'

export const format_decimal = (value) => is_missing(value) ? 'N/A' : value.toFixed(2)

export const format_number = (value) => is_missing(value) ? 'N/A' : value.toLocaleString('en-US')

export const format_stake = (lamports) => is_missing(lamports) ? 'N/A' : format_number(Math.round(lamports / LAMPORTS_PER_SOL))
