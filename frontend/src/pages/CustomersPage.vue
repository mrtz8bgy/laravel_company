<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useDate } from '../lib/date'
import { useUiStore } from '../stores/ui'

type Desk = {
  desks: string[]
  can_review: boolean
  can_customers: boolean
  can_orders: boolean
  can_manage_orders: boolean
  can_products: boolean
  can_manage_products: boolean
  pending_customers: number
}
type Customer = { uuid: string; status: string; organization_name?: string | null; phone?: string | null; user?: { name: string; email: string } }
type Product = { uuid: string; name: string; sku?: string | null; description?: string | null; unit_price: number; stock: number | null; is_active: boolean }
type Order = { uuid: string; number: string; status: string; total_amount: number; created_at: string; customer?: Customer; items?: { name: string; quantity: number }[] }
type Thread = { uuid: string; desk: string; subject: string; status: string; customer?: Customer; messages?: { body: string; is_staff: boolean; created_at: string; author?: { name: string } | null }[] }
type Ticket = Thread & { number: string; priority: string }

const ui = useUiStore()
const { t } = useI18n()
const dates = useDate()
const desk = ref<Desk | null>(null)
const tab = ref('customers')
const customers = ref<Customer[]>([])
const products = ref<Product[]>([])
const orders = ref<Order[]>([])
const threads = ref<Thread[]>([])
const tickets = ref<Ticket[]>([])
const selected = ref<Thread | null>(null)
const selectedTicket = ref<Ticket | null>(null)
const messageDesk = ref('sales')
const reply = ref('')
const reviewNote = ref('')
const productForm = ref({ name: '', sku: '', description: '', unit_price: 0, stock: null as number | null, is_active: true })

const tabs = computed(() => {
  if (!desk.value) return []
  return [
    desk.value.can_customers ? 'customers' : '',
    desk.value.can_products ? 'products' : '',
    desk.value.can_orders ? 'orders' : '',
    desk.value.desks.length ? 'messages' : '',
    desk.value.desks.length ? 'tickets' : '',
  ].filter(Boolean)
})

function money(value: number) {
  return new Intl.NumberFormat('fa-IR').format(value)
}

async function loadDesk() {
  desk.value = (await api<Desk>('/portal/desk')).data
  if (!tabs.value.includes(tab.value)) tab.value = tabs.value[0] || 'messages'
  if (desk.value.desks.length) messageDesk.value = desk.value.desks[0]
}

async function loadCustomers() {
  if (!desk.value?.can_customers) return
  customers.value = (await api<Customer[]>('/portal/desk/customers')).data
}

async function loadProducts() {
  if (!desk.value?.can_products) return
  products.value = (await api<Product[]>('/portal/desk/products')).data
}

async function loadOrders() {
  if (!desk.value?.can_orders) return
  orders.value = (await api<Order[]>('/portal/desk/orders')).data
}

async function loadThreads() {
  if (!desk.value?.desks.includes(messageDesk.value)) return
  threads.value = (await api<Thread[]>('/portal/desk/threads?desk=' + messageDesk.value)).data
  tickets.value = (await api<Ticket[]>('/portal/desk/tickets?desk=' + messageDesk.value)).data
}

async function refresh() {
  await loadDesk()
  await Promise.all([loadCustomers(), loadProducts(), loadOrders(), loadThreads()])
}

onMounted(refresh)

async function review(customer: Customer, decision: 'approve' | 'reject') {
  try {
    await api('/portal/desk/customers/' + customer.uuid + '/review', {
      method: 'POST',
      body: JSON.stringify({ decision, review_note: reviewNote.value || null }),
    })
    ui.toast(decision === 'approve' ? t('approve') : t('reject'))
    await refresh()
  } catch (err) {
    ui.toast(err instanceof ApiError ? err.message : 'Error', 'bad')
  }
}

async function saveProduct() {
  try {
    await api('/portal/desk/products', {
      method: 'POST',
      body: JSON.stringify({ ...productForm.value, sku: productForm.value.sku || null }),
    })
    productForm.value = { name: '', sku: '', description: '', unit_price: 0, stock: null, is_active: true }
    await loadProducts()
  } catch (err) {
    ui.toast(err instanceof ApiError ? err.message : 'Error', 'bad')
  }
}

async function setOrder(order: Order, status: string) {
  await api('/portal/desk/orders/' + order.uuid, { method: 'PATCH', body: JSON.stringify({ status }) })
  await loadOrders()
}

async function openThread(thread: Thread) {
  selected.value = (await api<Thread>('/portal/desk/threads/' + thread.uuid)).data
}

async function openTicket(ticket: Ticket) {
  selectedTicket.value = (await api<Ticket>('/portal/desk/tickets/' + ticket.uuid)).data
}

async function sendTicketReply() {
  if (!selectedTicket.value) return
  selectedTicket.value = (await api<Ticket>('/portal/desk/tickets/' + selectedTicket.value.uuid + '/replies', {
    method: 'POST',
    body: JSON.stringify({ body: reply.value, status: 'answered' }),
  })).data
  reply.value = ''
  await loadThreads()
}

async function sendReply() {
  if (!selected.value) return
  selected.value = (await api<Thread>('/portal/desk/threads/' + selected.value.uuid + '/replies', {
    method: 'POST',
    body: JSON.stringify({ body: reply.value }),
  })).data
  reply.value = ''
  await loadThreads()
}
</script>

<template>
  <div class="grid gap-5">
    <header>
      <p class="kicker">{{ t('customerPortal') }}</p>
      <h1 class="mt-2 text-3xl font-semibold">{{ t('customerDesk') }}</h1>
      <p v-if="desk?.pending_customers" class="mt-2 text-sm text-copper">{{ t('approvalsQueue') }}: {{ desk.pending_customers }}</p>
    </header>
    <div class="flex flex-wrap gap-2">
      <button v-for="item in tabs" :key="item" class="btn" :class="tab === item ? 'btn-primary' : 'btn-ghost'" @click="tab = item">{{ item === 'tickets' ? t('deskTickets') : t(item) }}</button>
    </div>

    <section v-if="tab === 'customers'" class="panel p-5">
      <label class="field mb-4 max-w-md"><span>{{ t('reviewNote') }}</span><input v-model="reviewNote" /></label>
      <div class="sheet">
        <table>
          <thead><tr><th>{{ t('name') }}</th><th>{{ t('email') }}</th><th>{{ t('organizationName') }}</th><th>{{ t('status') }}</th><th></th></tr></thead>
          <tbody>
            <tr v-for="customer in customers" :key="customer.uuid">
              <td>{{ customer.user?.name }}</td>
              <td>{{ customer.user?.email }}</td>
              <td>{{ customer.organization_name }}</td>
              <td><span class="badge">{{ t('status_' + customer.status) }}</span></td>
              <td v-if="desk?.can_review && customer.status !== 'active'" class="space-x-2 space-x-reverse">
                <button class="btn btn-primary" @click="review(customer, 'approve')">{{ t('approve') }}</button>
                <button class="btn btn-ghost" @click="review(customer, 'reject')">{{ t('reject') }}</button>
              </td>
              <td v-else />
            </tr>
            <tr v-if="!customers.length"><td colspan="5" class="text-muted">{{ t('noRows') }}</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <section v-if="tab === 'products'" class="grid gap-4">
      <form v-if="desk?.can_manage_products" class="panel grid gap-3 p-5 sm:grid-cols-2" @submit.prevent="saveProduct">
        <label class="field"><span>{{ t('name') }}</span><input v-model="productForm.name" required /></label>
        <label class="field"><span>{{ t('sku') }}</span><input v-model="productForm.sku" /></label>
        <label class="field"><span>{{ t('price') }}</span><input v-model.number="productForm.unit_price" type="number" min="0" required /></label>
        <label class="field"><span>{{ t('stock') }}</span><input v-model.number="productForm.stock" type="number" min="0" /></label>
        <label class="field sm:col-span-2"><span>{{ t('description') }}</span><textarea v-model="productForm.description" rows="2" /></label>
        <button class="btn btn-primary w-fit">{{ t('create') }}</button>
      </form>
      <div class="sheet">
        <table>
          <thead><tr><th>{{ t('product') }}</th><th>{{ t('sku') }}</th><th>{{ t('price') }}</th><th>{{ t('stock') }}</th></tr></thead>
          <tbody>
            <tr v-for="product in products" :key="product.uuid">
              <td>{{ product.name }}</td>
              <td>{{ product.sku }}</td>
              <td>{{ money(product.unit_price) }}</td>
              <td>{{ product.stock ?? '—' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <section v-if="tab === 'orders'" class="sheet">
      <table>
        <thead><tr><th>{{ t('orderNumber') }}</th><th>{{ t('customers') }}</th><th>{{ t('price') }}</th><th>{{ t('date') }}</th><th>{{ t('orderStatus') }}</th></tr></thead>
        <tbody>
          <tr v-for="order in orders" :key="order.uuid">
            <td>
              <p class="font-medium">{{ order.number }}</p>
              <p v-for="item in order.items" :key="item.name" class="text-xs text-muted">{{ item.name }} × {{ item.quantity }}</p>
            </td>
            <td>{{ order.customer?.user?.name }}</td>
            <td>{{ money(order.total_amount) }}</td>
            <td>{{ dates.formatDate(order.created_at) }}</td>
            <td>
              <select v-if="desk?.can_manage_orders" class="input" :value="order.status" @change="setOrder(order, ($event.target as HTMLSelectElement).value)">
                <option value="submitted">{{ t('status_submitted') }}</option>
                <option value="reviewing">{{ t('status_reviewing') }}</option>
                <option value="confirmed">{{ t('status_confirmed') }}</option>
                <option value="rejected">{{ t('status_rejected') }}</option>
                <option value="fulfilled">{{ t('status_fulfilled') }}</option>
              </select>
              <span v-else class="badge">{{ t('status_' + order.status) }}</span>
            </td>
          </tr>
          <tr v-if="!orders.length"><td colspan="5" class="text-muted">{{ t('noRows') }}</td></tr>
        </tbody>
      </table>
    </section>

    <section v-if="tab === 'messages'" class="grid gap-4 lg:grid-cols-[.8fr_1fr]">
      <div class="panel p-4">
        <label class="field">
          <span>{{ t('desk') }}</span>
          <select v-model="messageDesk" @change="loadThreads">
            <option v-for="item in desk?.desks || []" :key="item" :value="item">{{ t('desk_' + item) }}</option>
          </select>
        </label>
        <button v-for="thread in threads" :key="thread.uuid" class="mt-3 block w-full rounded-2xl border border-line px-3 py-3 text-start" @click="openThread(thread)">
          <span class="badge">{{ t('status_' + thread.status) }}</span>
          <p class="mt-2 font-medium">{{ thread.subject }}</p>
          <p class="text-xs text-muted">{{ thread.customer?.user?.name }}</p>
        </button>
        <p v-if="!threads.length" class="mt-3 text-sm text-muted">{{ t('noRows') }}</p>
      </div>
      <div v-if="selected && tab === 'messages'" class="panel p-5">
        <h2 class="font-semibold">{{ selected.subject }}</h2>
        <article v-for="(message, index) in selected.messages" :key="index" class="mt-3 rounded-2xl px-4 py-3" :class="message.is_staff ? 'bg-mint' : 'bg-copper-soft'">
          <p class="text-xs text-muted">{{ message.author?.name }} · {{ dates.formatDateTime(message.created_at) }}</p>
          <p class="mt-1 whitespace-pre-wrap text-sm">{{ message.body }}</p>
        </article>
        <form class="mt-4 grid gap-3" @submit.prevent="sendReply">
          <label class="field"><span>{{ t('reply') }}</span><textarea v-model="reply" rows="3" required /></label>
          <button class="btn btn-primary w-fit">{{ t('reply') }}</button>
        </form>
      </div>
    </section>

    <section v-if="tab === 'tickets'" class="grid gap-4 lg:grid-cols-[.8fr_1fr]">
      <div class="panel p-4">
        <label class="field">
          <span>{{ t('desk') }}</span>
          <select v-model="messageDesk" @change="loadThreads">
            <option v-for="item in desk?.desks || []" :key="item" :value="item">{{ t('desk_' + item) }}</option>
          </select>
        </label>
        <button v-for="ticket in tickets" :key="ticket.uuid" class="mt-3 block w-full rounded-2xl border border-line px-3 py-3 text-start" @click="openTicket(ticket)">
          <span class="badge">{{ ticket.number }}</span>
          <span class="badge ms-2">{{ t('status_' + ticket.status) }}</span>
          <p class="mt-2 font-medium">{{ ticket.subject }}</p>
          <p class="text-xs text-muted">{{ ticket.customer?.user?.name }} · {{ t('priority_' + ticket.priority) }}</p>
        </button>
        <p v-if="!tickets.length" class="mt-3 text-sm text-muted">{{ t('noRows') }}</p>
      </div>
      <div v-if="selectedTicket" class="panel p-5">
        <h2 class="font-semibold">{{ selectedTicket.number }} · {{ selectedTicket.subject }}</h2>
        <article v-for="(message, index) in selectedTicket.messages" :key="index" class="mt-3 rounded-2xl px-4 py-3" :class="message.is_staff ? 'bg-mint' : 'bg-copper-soft'">
          <p class="text-xs text-muted">{{ message.author?.name }} · {{ dates.formatDateTime(message.created_at) }}</p>
          <p class="mt-1 whitespace-pre-wrap text-sm">{{ message.body }}</p>
        </article>
        <form class="mt-4 grid gap-3" @submit.prevent="sendTicketReply">
          <label class="field"><span>{{ t('reply') }}</span><textarea v-model="reply" rows="3" required /></label>
          <button class="btn btn-primary w-fit">{{ t('reply') }}</button>
        </form>
      </div>
    </section>
  </div>
</template>
