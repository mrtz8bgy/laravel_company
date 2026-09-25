<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useDate } from '../lib/date'
import { useUiStore } from '../stores/ui'

type Product = { uuid: string; name: string; description?: string | null; unit_price: number; currency: string; stock: number | null }
type Order = { uuid: string; number: string; status: string; total_amount: number; currency: string; created_at: string; note?: string | null; items?: { name: string; quantity: number; line_total: number }[] }

const ui = useUiStore()
const { t } = useI18n()
const dates = useDate()
const products = ref<Product[]>([])
const orders = ref<Order[]>([])
const qty = ref<Record<string, number>>({})
const note = ref('')
const locked = ref(false)
const loading = ref(false)

function money(value: number) {
  return new Intl.NumberFormat('fa-IR').format(value) + ' ' + t('rial')
}

async function load() {
  const me = await api<{ customer: { status: string } }>('/portal/me')
  locked.value = me.data.customer.status !== 'active'
  products.value = (await api<Product[]>('/portal/products')).data
  orders.value = (await api<Order[]>('/portal/orders')).data
  for (const product of products.value) qty.value[product.uuid] = qty.value[product.uuid] || 0
}

onMounted(load)

async function submit() {
  const items = products.value
    .filter((product) => (qty.value[product.uuid] || 0) > 0)
    .map((product) => ({ product_uuid: product.uuid, quantity: qty.value[product.uuid] }))
  if (!items.length) return
  loading.value = true
  try {
    await api('/portal/orders', { method: 'POST', body: JSON.stringify({ note: note.value || null, items }) })
    note.value = ''
    for (const key of Object.keys(qty.value)) qty.value[key] = 0
    ui.toast(t('placeOrder'))
    await load()
  } catch (err) {
    ui.toast(err instanceof ApiError ? err.message : 'Error', 'bad')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="grid gap-5">
    <section class="panel p-6">
      <p class="kicker">{{ t('customerPortal') }}</p>
      <h1 class="mt-2 text-3xl font-semibold">{{ t('placeOrder') }}</h1>
      <p v-if="locked" class="mt-4 rounded-2xl bg-copper-soft px-4 py-3 text-sm">{{ t('awaitingApproval') }}</p>
      <div v-else class="mt-5 grid gap-3">
        <article v-for="product in products" :key="product.uuid" class="grid gap-3 rounded-2xl border border-line p-4 sm:grid-cols-[1fr_auto]">
          <div>
            <h2 class="font-semibold">{{ product.name }}</h2>
            <p v-if="product.description" class="mt-1 text-sm text-muted">{{ product.description }}</p>
            <p class="mt-2 text-sm">{{ money(product.unit_price) }} <span v-if="product.stock !== null" class="text-muted">· {{ t('stock') }} {{ product.stock }}</span></p>
          </div>
          <label class="field w-28">
            <span>{{ t('quantity') }}</span>
            <input v-model.number="qty[product.uuid]" type="number" min="0" max="999" />
          </label>
        </article>
        <p v-if="!products.length" class="text-sm text-muted">{{ t('noRows') }}</p>
        <label class="field"><span>{{ t('orderNote') }}</span><textarea v-model="note" rows="3" /></label>
        <button class="btn btn-primary w-fit" :disabled="loading" @click="submit">{{ t('placeOrder') }}</button>
      </div>
    </section>
    <section class="panel p-6">
      <h2 class="font-semibold">{{ t('myOrders') }}</h2>
      <div class="sheet mt-4">
        <table>
          <thead>
            <tr>
              <th>{{ t('orderNumber') }}</th>
              <th>{{ t('orderStatus') }}</th>
              <th>{{ t('price') }}</th>
              <th>{{ t('date') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in orders" :key="order.uuid">
              <td>
                <p class="font-medium">{{ order.number }}</p>
                <p v-for="item in order.items" :key="item.name" class="text-xs text-muted">{{ item.name }} × {{ item.quantity }}</p>
              </td>
              <td><span class="badge">{{ t('status_' + order.status) }}</span></td>
              <td>{{ money(order.total_amount) }}</td>
              <td>{{ dates.formatDate(order.created_at) }}</td>
            </tr>
            <tr v-if="!orders.length"><td colspan="4" class="text-muted">{{ t('noRows') }}</td></tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
