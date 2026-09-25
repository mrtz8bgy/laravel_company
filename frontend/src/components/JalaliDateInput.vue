<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useDate } from '../lib/date'
import { isoToJalali, jalaliText, jalaliToIso, parseJalaliText } from '../lib/jalali'

const props = defineProps<{ modelValue: string; required?: boolean }>()
const emit = defineEmits<{ 'update:modelValue': [value: string] }>()

const { t } = useI18n()
const { isJalali, today, shortDate } = useDate()

const text = ref('')
const invalid = ref(false)

const placeholder = computed(() =>
  isJalali.value ? jalaliText({ year: 1405, month: 7, day: 3 }) : '2026-09-25',
)

watch(
  () => props.modelValue,
  (value) => {
    if (!isJalali.value) {
      text.value = value || ''
      invalid.value = false

      return
    }
    const parts = value ? isoToJalali(value.slice(0, 10)) : null
    text.value = parts ? jalaliText(parts) : value || ''
    invalid.value = false
  },
  { immediate: true },
)

function commit(raw: string) {
  if (!isJalali.value) {
    emit('update:modelValue', raw)

    return
  }

  if (raw.trim() === '') {
    invalid.value = false
    text.value = ''
    emit('update:modelValue', '')

    return
  }

  const parts = parseJalaliText(raw)
  if (!parts) {
    invalid.value = true

    return
  }

  invalid.value = false
  text.value = jalaliText(parts)
  emit('update:modelValue', jalaliToIso(parts))
}

function useToday() {
  emit('update:modelValue', today())
}
</script>

<template>
  <span class="date-input">
    <input
      v-if="isJalali"
      :value="text"
      :class="{ 'is-invalid': invalid }"
      :placeholder="placeholder"
      inputmode="numeric"
      autocomplete="off"
      :required="required"
      @change="commit(($event.target as HTMLInputElement).value)"
      @blur="commit(($event.target as HTMLInputElement).value)"
    />
    <input
      v-else
      type="date"
      :value="(modelValue || '').slice(0, 10)"
      :required="required"
      @change="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    />
    <button type="button" class="date-input-today" :title="shortDate(today())" @click="useToday">
      {{ t('today') }}
    </button>
  </span>
</template>
