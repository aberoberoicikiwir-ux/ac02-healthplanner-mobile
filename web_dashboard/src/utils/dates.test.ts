import { describe, expect, it } from 'vitest'
import {
  addDays,
  formatWeekRange,
  getDateRange,
  getNextMonday,
  parseIsoDate,
  toIsoDate,
} from './dates'

describe('dates', () => {
  it('bolak-balik ISO date tanpa pergeseran hari', () => {
    expect(toIsoDate(parseIsoDate('2026-11-23'))).toBe('2026-11-23')
  })

  it('menambahkan hari dengan benar', () => {
    expect(toIsoDate(addDays(parseIsoDate('2026-11-23'), 6))).toBe(
      '2026-11-29',
    )
  })

  it('membuat rentang 7 hari yang valid', () => {
    const range = getDateRange(7)
    expect(range.from).toHaveLength(10)
    expect(range.to).toHaveLength(10)
    expect(range.from <= range.to).toBe(true)
  })

  it('Senin berikutnya selalu hari Senin', () => {
    expect(parseIsoDate(getNextMonday()).getDay()).toBe(1)
  })

  it('format rentang minggu memuat tanggal awal dan akhir', () => {
    const formatted = formatWeekRange('2026-11-23')
    expect(formatted).toContain('23')
    expect(formatted).toContain('29')
  })
})
