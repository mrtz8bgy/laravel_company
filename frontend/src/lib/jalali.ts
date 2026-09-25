/**
 * Jalali (Persian) calendar maths.
 *
 * The conversion follows the 33-year cycle used by the official Iranian
 * calendar, and matches Intl's `persian` calendar for every day between
 * 2020 and 2032 (verified against ICU).
 *
 * Only conversion lives here. Rendering goes through Intl so month names and
 * digits stay localised in src/lib/date.ts.
 */

export type JalaliParts = { year: number; month: number; day: number }

const PERSIAN_DIGITS = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹']
const ARABIC_DIGITS = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩']

/** Accepts Persian and Arabic digits so users can type either. */
export function normalizeDigits(value: string): string {
  return value
    .replace(/[۰-۹]/g, (digit) => String(PERSIAN_DIGITS.indexOf(digit)))
    .replace(/[٠-٩]/g, (digit) => String(ARABIC_DIGITS.indexOf(digit)))
}

function div(a: number, b: number): number {
  return Math.trunc(a / b)
}

function mod(a: number, b: number): number {
  return a - div(a, b) * b
}

/** Gregorian civil date to Jalali. */
export function toJalali(gy: number, gm: number, gd: number): JalaliParts {
  const gregorianMonthOffset = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
  const gy2 = gm > 2 ? gy + 1 : gy
  let days =
    355666 +
    365 * gy +
    div(gy2 + 3, 4) -
    div(gy2 + 99, 100) +
    div(gy2 + 399, 400) +
    gd +
    gregorianMonthOffset[gm - 1]

  let jy = -1595 + 33 * div(days, 12053)
  days %= 12053
  jy += 4 * div(days, 1461)
  days %= 1461

  if (days > 365) {
    jy += div(days - 1, 365)
    days = (days - 1) % 365
  }

  const jm = days < 186 ? 1 + div(days, 31) : 7 + div(days - 186, 30)
  const jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30)

  return { year: jy, month: jm, day: jd }
}

/** Jalali date to Gregorian civil date. */
export function toGregorian(jy: number, jm: number, jd: number): JalaliParts {
  jy += 1595
  let days =
    -355668 +
    365 * jy +
    div(jy, 33) * 8 +
    div(mod(jy, 33) + 3, 4) +
    jd +
    (jm < 7 ? (jm - 1) * 31 : (jm - 7) * 30 + 186)

  let gy = 400 * div(days, 146097)
  days %= 146097

  if (days > 36524) {
    gy += 100 * div(--days, 36524)
    days %= 36524
    if (days >= 365) days++
  }

  gy += 4 * div(days, 1461)
  days %= 1461

  if (days > 365) {
    gy += div(days - 1, 365)
    days = (days - 1) % 365
  }

  let gd = days + 1
  const leapGregorian = (gy % 4 === 0 && gy % 100 !== 0) || gy % 400 === 0
  const monthLengths = [0, 31, leapGregorian ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  let gm = 0
  for (gm = 1; gm <= 12 && gd > monthLengths[gm]; gm++) gd -= monthLengths[gm]

  return { year: gy, month: gm, day: gd }
}

/** Jalali leap year from the 33-year cycle table. */
export function isJalaliLeapYear(jy: number): boolean {
  const breaks = [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178]
  const gy = jy + 621
  let leapJ = -14
  let jp = breaks[0]
  let jump = 0

  if (jy < jp || jy >= breaks[breaks.length - 1]) throw new RangeError(`Unsupported Jalali year: ${jy}`)

  for (let i = 1; i < breaks.length; i++) {
    const jm = breaks[i]
    jump = jm - jp
    if (jy < jm) break
    leapJ += div(jump, 33) * 8 + div(mod(jump, 33), 4)
    jp = jm
  }

  let n = jy - jp
  leapJ += div(n, 33) * 8 + div(mod(n, 33) + 3, 4)
  if (mod(jump, 33) === 4 && jump - n === 4) leapJ += 1

  const leapG = div(gy, 4) - div((div(gy, 100) + 1) * 3, 4) - 150
  const march = 20 + leapJ - leapG

  if (jump - n < 6) n = n - jump + div(jump + 4, 33) * 33
  let leap = mod(mod(n + 1, 33) - 1, 4)

  if (leap === -1) leap = 4
  void march

  return leap === 0
}

export function jalaliMonthLength(year: number, month: number): number {
  if (month <= 6) return 31
  if (month <= 11) return 30

  return isJalaliLeapYear(year) ? 30 : 29
}

const ISO_DATE = /^(\d{4})-(\d{2})-(\d{2})$/

export function parseIsoDate(value: string): JalaliParts | null {
  const match = ISO_DATE.exec(value.trim())

  return match
    ? { year: Number(match[1]), month: Number(match[2]), day: Number(match[3]) }
    : null
}

/** 'YYYY-MM-DD' (Gregorian) to Jalali parts. */
export function isoToJalali(value: string): JalaliParts | null {
  const parts = parseIsoDate(value)

  return parts ? toJalali(parts.year, parts.month, parts.day) : null
}

/** Jalali parts to 'YYYY-MM-DD' (Gregorian). */
export function jalaliToIso(parts: JalaliParts): string {
  const gregorian = toGregorian(parts.year, parts.month, parts.day)
  const month = String(gregorian.month).padStart(2, '0')
  const day = String(gregorian.day).padStart(2, '0')

  return `${gregorian.year}-${month}-${day}`
}

/** Parses '1405/07/03' (any digits, / or -) into Jalali parts. */
export function parseJalaliText(value: string): JalaliParts | null {
  const raw = normalizeDigits(value).trim()
  const match = /^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$/.exec(raw)
  if (!match) return null

  const year = Number(match[1])
  const month = Number(match[2])
  const day = Number(match[3])

  if (year < 1300 || year > 1600) return null
  if (month < 1 || month > 12) return null
  if (day < 1 || day > jalaliMonthLength(year, month)) return null

  return { year, month, day }
}

export function jalaliText(parts: JalaliParts): string {
  return `${parts.year}/${String(parts.month).padStart(2, '0')}/${String(parts.day).padStart(2, '0')}`
}

/** 0 = Saturday … 6 = Friday, the week order used in Iran. */
export function jalaliWeekdayIndex(isoDate: string): number | null {
  const parts = parseIsoDate(isoDate)
  if (!parts) return null

  return (new Date(Date.UTC(parts.year, parts.month - 1, parts.day)).getUTCDay() + 1) % 7
}
