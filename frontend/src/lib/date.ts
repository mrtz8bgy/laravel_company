import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { isoToJalali, jalaliText, jalaliWeekdayIndex, type JalaliParts } from './jalali'

const DEFAULT_TIMEZONE = 'Asia/Tehran'

/**
 * Date and time formatting for the signed-in company.
 *
 * Dates are stored and exchanged as ISO (Gregorian) and rendered in the
 * company calendar system and timezone. Nothing here mutates data.
 */
export function useDate() {
  const auth = useAuthStore()
  const { t, locale } = useI18n()

  const timezone = computed(() => auth.company?.timezone || DEFAULT_TIMEZONE)
  const calendar = computed(() => (auth.company?.calendar === 'gregorian' ? 'gregorian' : 'jalali'))
  const isJalali = computed(() => calendar.value === 'jalali')

  /** Intl locale: Jalali always renders year-first with Latin digits. */
  const dateLocale = computed(() =>
    isJalali.value ? 'fa-IR-u-nu-latn-ca-persian' : locale.value === 'fa' ? 'fa-IR-u-nu-latn' : 'en-GB',
  )

  function atUtcNoon(value: string): Date | null {
    if (!value) return null
    const date = value.includes('T') ? new Date(value) : new Date(`${value.slice(0, 10)}T12:00:00Z`)

    return Number.isNaN(date.getTime()) ? null : date
  }

  function formatDate(value?: string | null): string {
    if (!value) return '—'
    const date = atUtcNoon(value)
    if (!date) return '—'

    // Built at UTC noon, so formatting it in UTC keeps the calendar day stable.
    return new Intl.DateTimeFormat(dateLocale.value, {
      timeZone: 'UTC',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(date)
  }

  function formatTime(value?: string | null): string {
    if (!value) return '—'
    const date = new Date(value)
    if (Number.isNaN(date.getTime())) return '—'

    return new Intl.DateTimeFormat('en-GB', {
      timeZone: timezone.value,
      hour: '2-digit',
      minute: '2-digit',
      hourCycle: 'h23',
    }).format(date)
  }

  function formatDateTime(value?: string | null): string {
    if (!value) return '—'

    return `${formatDate(value)} · ${formatTime(value)}`
  }

  function jalaliParts(value?: string | null): JalaliParts | null {
    if (!value) return null

    return isoToJalali(value.slice(0, 10))
  }

  /** e.g. 1405/07/03, in the company calendar system. */
  function shortDate(value?: string | null): string {
    if (!value) return '—'
    if (!isJalali.value) return formatDate(value)
    const parts = jalaliParts(value)

    return parts ? jalaliText(parts) : '—'
  }

  function weekdayName(value?: string | null): string {
    if (!value) return ''
    if (!isJalali.value) {
      const date = atUtcNoon(value)
      if (!date) return ''

      return new Intl.DateTimeFormat(locale.value === 'fa' ? 'fa-IR' : 'en-GB', {
        timeZone: 'UTC',
        weekday: 'long',
      }).format(date)
    }
    const index = jalaliWeekdayIndex(value.slice(0, 10))

    return index === null ? '' : t(`weekday_${index}`)
  }

  /** Weekday index for Jalali week order: 0 = Saturday. */
  function weekdayIndex(value?: string | null): number | null {
    if (!value) return null

    return jalaliWeekdayIndex(value.slice(0, 10))
  }

  /** Today as 'YYYY-MM-DD' inside the company timezone. */
  function today(): string {
    const parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: timezone.value,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date())

    return parts.replace(/\//g, '-')
  }

  /** Offset of the company timezone at that instant, e.g. '+03:30'. */
  function offsetAt(date: Date): string {
    const formatted = new Intl.DateTimeFormat('en-US', {
      timeZone: timezone.value,
      timeZoneName: 'longOffset',
    })
      .formatToParts(date)
      .find((part) => part.type === 'timeZoneName')?.value

    return (formatted || 'GMT+00:00').replace('GMT', '')
  }

  /**
   * Builds an ISO datetime with the company offset, which is what the API
   * expects when a manager corrects a clock time.
   */
  function localToIso(date: string, time: string): string {
    const naive = new Date(`${date}T${time}:00`)
    const offset = offsetAt(naive)
    const iso = naive.toISOString().slice(0, 19)

    return `${iso}${offset}`
  }

  function shiftDays(date: string, days: number): string {
    const parts = date.split('-').map(Number)
    const shifted = new Date(Date.UTC(parts[0], parts[1] - 1, parts[2] + days))

    return shifted.toISOString().slice(0, 10)
  }

  function duration(minutes?: number | null): string {
    const total = Math.max(0, Math.round(Number(minutes || 0)))
    const hours = Math.floor(total / 60)
    const rest = total % 60

    if (hours && rest) return `${hours} ${t('hoursShort')} ${rest} ${t('minutes')}`
    if (hours) return `${hours} ${t('hoursShort')}`

    return `${rest} ${t('minutes')}`
  }

  /** Signed balance such as overtime or shortfall. */
  function balance(minutes?: number | null): string {
    const total = Math.round(Number(minutes || 0))
    if (total === 0) return `0 ${t('minutes')}`
    const sign = total > 0 ? '+' : '−'

    return `${sign}${duration(Math.abs(total))}`
  }

  function clockTime(value?: string | null): string {
    const date = new Date()

    return value ? formatTime(value) : formatTime(date.toISOString())
  }

  return {
    timezone,
    calendar,
    isJalali,
    formatDate,
    formatTime,
    formatDateTime,
    shortDate,
    weekdayName,
    weekdayIndex,
    jalaliParts,
    today,
    localToIso,
    shiftDays,
    duration,
    balance,
    clockTime,
  }
}
