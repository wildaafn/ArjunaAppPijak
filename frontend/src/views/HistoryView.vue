<template>
  <div class="h-full flex flex-col">
    <!-- Header -->
    <header class="mb-xl">
      <h1 class="font-display-lg text-headline-lg-mobile md:text-display-lg text-on-surface mb-xs">Price History &amp; Audit</h1>
      <p class="font-body-lg text-body-lg text-on-surface-variant max-w-2xl">Review historical trends and past prediction accuracy across the archipelago market ecosystem.</p>
    </header>

    <!-- Main Grid Layout -->
    <div class="grid grid-cols-1 xl:grid-cols-12 gap-gutter max-w-container-max flex-1 pb-lg">
      <!-- Control Panel (Left Column on Desktop) -->
      <div class="xl:col-span-3 flex flex-col gap-md">
        <div class="glass-card rounded-xl p-md flex flex-col gap-md sticky top-lg">
          <h2 class="font-title-md text-title-md text-on-surface flex items-center gap-sm mb-xs">
            <span class="material-symbols-outlined text-primary">tune</span>
            Analysis Filters
          </h2>
          
          <!-- Filter: Commodity -->
          <div class="flex flex-col gap-xs">
            <label class="font-label-caps text-label-caps text-on-surface-variant">Select Commodity</label>
            <div class="relative">
              <select v-model="selectedCommodity" class="ghost-input w-full p-sm rounded-lg font-body-sm text-body-sm appearance-none cursor-pointer pr-10">
                <option v-for="c in commodities" :key="c" :value="c" class="bg-surface text-on-surface">{{ c }}</option>
              </select>
              <span class="material-symbols-outlined absolute right-sm top-1/2 -translate-y-1/2 pointer-events-none text-on-surface-variant">arrow_drop_down</span>
            </div>
          </div>
          
          <!-- Filter: Time Range -->
          <div class="flex flex-col gap-xs">
            <label class="font-label-caps text-label-caps text-on-surface-variant">Time Range</label>
            <div class="grid grid-cols-2 gap-xs">
              <label :class="{'bg-white/10 border-cyan/30': timeRange === '30d'}" class="flex items-center justify-center p-sm rounded-lg border border-white/10 bg-white/5 cursor-pointer hover:bg-white/10 transition-colors">
                <input class="hidden" name="time_range" type="radio" value="30d" v-model="timeRange"/>
                <span class="font-body-sm text-body-sm text-on-surface">30 Days</span>
              </label>
              <label :class="{'bg-white/10 border-cyan/30': timeRange === '90d'}" class="flex items-center justify-center p-sm rounded-lg border border-white/10 bg-white/5 cursor-pointer hover:bg-white/10 transition-colors">
                <input class="hidden" name="time_range" type="radio" value="90d" v-model="timeRange"/>
                <span class="font-body-sm text-body-sm text-on-surface">3 Months</span>
              </label>
              <label :class="{'bg-white/10 border-cyan/30': timeRange === '1y'}" class="flex items-center justify-center p-sm rounded-lg border border-white/10 bg-white/5 cursor-pointer hover:bg-white/10 transition-colors">
                <input class="hidden" name="time_range" type="radio" value="1y" v-model="timeRange"/>
                <span class="font-body-sm text-body-sm text-on-surface">1 Year</span>
              </label>
              <label :class="{'bg-white/10 border-cyan/30': timeRange === 'all'}" class="flex items-center justify-center p-sm rounded-lg border border-white/10 bg-white/5 cursor-pointer hover:bg-white/10 transition-colors">
                <input class="hidden" name="time_range" type="radio" value="all" v-model="timeRange"/>
                <span class="font-body-sm text-body-sm text-on-surface">All Time</span>
              </label>
            </div>
          </div>
          
          <!-- CTA -->
          <button @click="fetchHistory" class="w-full mt-sm py-sm rounded-lg bg-secondary-container text-on-secondary-container font-title-md text-[14px] font-bold shadow-[0_4px_14px_rgba(250,189,0,0.2)] hover:shadow-[0_6px_20px_rgba(250,189,0,0.3)] hover:-translate-y-0.5 transition-all duration-200">
            Apply Filters
          </button>
        </div>
      </div>

      <!-- Content Panel (Right Column on Desktop) -->
      <div class="xl:col-span-9 flex flex-col gap-lg">
        <!-- Summary Cards Row -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-gutter">
          <div class="glass-card rounded-xl p-md flex flex-col gap-sm">
            <div class="flex items-center justify-between">
              <span class="font-label-caps text-label-caps text-on-surface-variant">Avg. Historical Price</span>
              <span class="material-symbols-outlined text-on-surface-variant text-[20px]">payments</span>
            </div>
            <div class="flex items-baseline gap-sm">
              <span class="font-data-mono text-[28px] text-on-surface">{{ formatPrice(averagePrice) }}</span>
              <span v-if="historyLog.length > 1" :class="trendDelta > 0 ? 'text-error' : 'text-primary'" class="font-body-sm text-[12px] flex items-center">
                <span class="material-symbols-outlined text-[14px]">{{ trendDelta > 0 ? 'trending_up' : 'trending_down' }}</span> {{ trendDelta > 0 ? '+' : '' }}{{ trendDelta }}%
              </span>
            </div>
            <span class="font-body-sm text-[12px] text-on-surface-variant">per Kg over selected period</span>
          </div>

          <div class="glass-card rounded-xl p-md flex flex-col gap-sm">
            <div class="flex items-center justify-between">
              <span class="font-label-caps text-label-caps text-on-surface-variant">Historical Volatility</span>
              <span class="material-symbols-outlined text-on-surface-variant text-[20px]">show_chart</span>
            </div>
            <div class="flex items-baseline gap-sm">
              <span class="font-title-md text-[24px] text-secondary">{{ volatilityLevel.text }}</span>
            </div>
            <div class="w-full bg-white/10 h-1.5 rounded-full mt-xs overflow-hidden">
              <div class="bg-secondary h-full rounded-full shadow-[0_0_8px_rgba(255,223,158,0.5)] transition-all duration-500" :style="{ width: `${volatilityLevel.pct}%` }"></div>
            </div>
          </div>

          <div class="glass-card rounded-xl p-md flex flex-col gap-sm">
            <div class="flex items-center justify-between">
              <span class="font-label-caps text-label-caps text-on-surface-variant">Prediction Accuracy</span>
              <span class="material-symbols-outlined text-on-surface-variant text-[20px]">verified</span>
            </div>
            <div class="flex items-baseline gap-sm">
              <span class="font-data-mono text-[28px] text-cyan-glow">{{ predictionAccuracy }}</span>
            </div>
            <span class="font-body-sm text-[12px] text-on-surface-variant">Average precision rating</span>
          </div>
        </div>

        <!-- Main Chart Card -->
        <div class="glass-card rounded-xl p-md flex flex-col gap-md">
          <div class="flex flex-col md:flex-row md:items-center justify-between gap-sm mb-sm">
            <h3 class="font-title-md text-title-md text-on-surface">Price Trajectory &amp; Model Audit</h3>
            <div class="flex items-center gap-sm bg-white/5 rounded-full p-xs border border-white/10">
              <div class="flex items-center gap-xs px-sm py-xs text-on-surface font-body-sm text-[12px]">
                <span class="w-2.5 h-2.5 rounded-full bg-white/40"></span>
                Actual Price
              </div>
              <div class="flex items-center gap-xs px-sm py-xs text-on-surface font-body-sm text-[12px]">
                <span class="w-2.5 h-2.5 rounded-full bg-[#00E5FF] shadow-[0_0_6px_#00E5FF] border border-dashed border-[#00E5FF]"></span>
                Past Predictions
              </div>
            </div>
          </div>
          
          <div class="relative w-auto h-[300px] md:h-[400px] mt-lg ml-16 mr-4 mb-6 border-b border-l border-white/10 flex items-end">
            <!-- Y-Axis Labels -->
            <div class="absolute left-0 top-0 h-full flex flex-col justify-between text-on-surface-variant font-label-caps text-label-caps -ml-16 py-2 w-14 text-right">
              <span>{{ formatK(chartMax) }}</span>
              <span>{{ formatK(chartMid) }}</span>
              <span>{{ formatK(chartMin) }}</span>
            </div>
            
            <!-- Grid Lines -->
            <div class="absolute inset-0 flex flex-col justify-between pointer-events-none py-2">
              <div class="w-full h-px bg-white/5"></div>
              <div class="w-full h-px bg-white/5"></div>
              <div class="w-full h-px bg-white/5"></div>
            </div>

            <!-- Chart States -->
            <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center text-on-surface-variant font-data-mono z-10">
                Loading historical data...
            </div>
            <div v-else-if="error" class="absolute inset-0 flex items-center justify-center text-error font-data-mono z-10">
                {{ error }}
            </div>
            <div v-else-if="historyLog.length === 0" class="absolute inset-0 flex items-center justify-center text-on-surface-variant font-data-mono z-10">
                No historical records found.
            </div>
            <div v-else class="w-full h-full relative z-10 py-4 px-2">
              <div class="w-full h-full relative">
                <!-- SVG Line Chart -->
                <svg viewBox="0 0 100 100" class="absolute inset-0 w-full h-full overflow-visible pointer-events-none" preserveAspectRatio="none">
                  <!-- Actual Line -->
                  <path :d="actualPath" fill="none" stroke="rgba(255,255,255,0.4)" stroke-width="2.5" vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round"></path>
                  <!-- Predicted Line -->
                  <path :d="predictedPath" fill="none" stroke="#00E5FF" stroke-width="2" stroke-dasharray="3,3" filter="drop-shadow(0px 0px 4px rgba(0,229,255,0.5))" vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>

                <!-- Interactive nodes (visible for <= 31 days) -->
                <template v-if="chronologicalData.length <= 31">
                  <div v-for="(item, index) in chronologicalData" :key="index" 
                      class="absolute w-4 h-4 -ml-2 -mt-2 rounded-full cursor-pointer z-20 group flex items-center justify-center" 
                      :style="{ left: `${getX(index, chronologicalData.length)}%`, top: `${getY(item.price)}%` }">
                      
                      <!-- Tooltip -->
                      <div class="absolute bottom-full mb-1 bg-black/85 backdrop-blur-md text-white text-[12px] px-sm py-xs rounded border border-white/10 opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none text-center shadow-xl z-30">
                          <span class="text-xs text-white/60 block">{{ item.date }}</span>
                          <strong>Actual: {{ formatPrice(item.price) }}</strong>
                          <span class="text-[10px] text-cyan block mt-1">Predicted: {{ formatPrice(item.predicted) }}</span>
                      </div>
                      
                      <!-- Point Indicator -->
                      <div class="w-2 h-2 rounded-full bg-white/70 transition-transform group-hover:scale-150"></div>
                  </div>
                </template>
              </div>
            </div>

            <!-- X-Axis Labels -->
            <div v-if="historyLog.length > 0" class="absolute bottom-0 left-0 w-full flex justify-between text-on-surface-variant font-label-caps text-label-caps -mb-6 px-2">
              <span>{{ startDateLabel }}</span>
              <span>Midpoint</span>
              <span>{{ endDateLabel }}</span>
            </div>
          </div>
        </div>

        <!-- Historical Log Table -->
        <div class="glass-card rounded-xl overflow-hidden flex flex-col">
          <div class="p-md border-b border-white/10 flex items-center justify-between bg-white/5">
            <h3 class="font-title-md text-title-md text-on-surface">Historical Log</h3>
            <button @click="exportToCSV" :disabled="isLoading || historyLog.length === 0" class="text-primary text-[14px] font-medium hover:text-primary-fixed transition-colors flex items-center gap-xs disabled:opacity-50 disabled:pointer-events-none">
              <span class="material-symbols-outlined text-[18px]">download</span> CSV
            </button>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse min-w-[600px]">
              <thead>
                <tr class="border-b border-white/10 bg-black/20">
                  <th class="p-sm pl-md font-label-caps text-label-caps text-on-surface-variant">Date</th>
                  <th class="p-sm font-label-caps text-label-caps text-on-surface-variant">Commodity</th>
                  <th class="p-sm font-label-caps text-label-caps text-on-surface-variant">Actual Price</th>
                  <th class="p-sm font-label-caps text-label-caps text-on-surface-variant">Predicted</th>
                  <th class="p-sm pr-md font-label-caps text-label-caps text-on-surface-variant text-right">Delta</th>
                </tr>
              </thead>
              <tbody class="font-body-sm text-body-sm text-on-surface">
                <tr v-if="isLoading">
                  <td colspan="5" class="p-md text-center text-on-surface-variant font-data-mono">Loading data...</td>
                </tr>
                <tr v-else-if="historyLog.length === 0">
                  <td colspan="5" class="p-md text-center text-on-surface-variant font-data-mono">No records found.</td>
                </tr>
                <tr v-else v-for="row in historyLog" :key="row.date" class="border-b border-white/5 hover:bg-white/5 transition-colors">
                  <td class="p-sm pl-md text-on-surface-variant font-data-mono">{{ row.date }}</td>
                  <td class="p-sm">{{ selectedCommodity }}</td>
                  <td class="p-sm font-data-mono">{{ formatPrice(row.price) }}</td>
                  <td class="p-sm font-data-mono text-cyan-glow">{{ formatPrice(row.predicted) }}</td>
                  <td class="p-sm pr-md text-right">
                    <span :class="row.delta > 0 ? 'bg-error/10 text-error border-error/20' : 'bg-primary/10 text-primary border-primary/20'" class="inline-flex items-center gap-xs text-[12px] px-xs py-[2px] rounded border">
                      {{ row.delta > 0 ? '+' : '' }}{{ row.delta.toFixed(1) }}%
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import api from '@/services/api'

const commodities = ref([])
const selectedCommodity = ref('Beras Kualitas Medium I')
const timeRange = ref('30d')
const historyLog = ref([])
const isLoading = ref(true)
const error = ref(null)

// Load commodities
const fetchCommodities = async () => {
  try {
    const res = await api.get('/commodities')
    commodities.value = res.data
    if (commodities.value.length > 0 && !commodities.value.includes(selectedCommodity.value)) {
      selectedCommodity.value = commodities.value[0]
    }
  } catch (err) {
    console.error("Failed to fetch commodities:", err)
  }
}

// Fetch historical data & model audit (fitted values)
const fetchHistory = async () => {
  isLoading.value = true
  error.value = null
  try {
    let days = 30
    if (timeRange.value === '90d') days = 90
    else if (timeRange.value === '1y') days = 365
    else if (timeRange.value === 'all') days = 2200 // Covers data starting from 2021

    const res = await api.get('/audit', {
      params: {
        subcategory: selectedCommodity.value,
        days: days
      }
    })

    const data = res.data || []
    
    const processed = data.map(item => ({
      date: item.date,
      price: item.actual_price,
      predicted: item.fitted_price,
      delta: item.residual_pct,
      errorPercent: Math.abs(item.residual_pct) / 100
    }))
    
    // Sort descending for display in table (newest first)
    historyLog.value = [...processed].reverse()
  } catch (err) {
    console.error("Failed to fetch historical/audit data:", err)
    error.value = "Gagal memuat data historis"
  } finally {
    isLoading.value = false
  }
}

// Compute Avg. Historical Price
const averagePrice = computed(() => {
  if (historyLog.value.length === 0) return 0
  const total = historyLog.value.reduce((acc, curr) => acc + curr.price, 0)
  return Math.round(total / historyLog.value.length)
})

// Compute trend delta over the selected period
const trendDelta = computed(() => {
  if (historyLog.value.length < 2) return 0
  const newest = historyLog.value[0].price
  const oldest = historyLog.value[historyLog.value.length - 1].price
  if (oldest === 0) return 0
  const diff = newest - oldest
  return ((diff / oldest) * 100).toFixed(1)
})

// Compute Volatility
const volatilityLevel = computed(() => {
  if (historyLog.value.length < 2) return { text: 'Low', pct: 25 }
  
  const mean = averagePrice.value
  const variance = historyLog.value.reduce((acc, curr) => acc + Math.pow(curr.price - mean, 2), 0) / historyLog.value.length
  const stdDev = Math.sqrt(variance)
  const cv = stdDev / mean // Coefficient of Variation
  
  if (cv < 0.02) {
    return { text: 'Low', pct: 25 }
  } else if (cv < 0.05) {
    return { text: 'Medium', pct: 55 }
  } else {
    return { text: 'High', pct: 85 }
  }
})

// Compute Prediction Accuracy
const predictionAccuracy = computed(() => {
  if (historyLog.value.length === 0) return 'N/A'
  const mape = historyLog.value.reduce((acc, r) => acc + Math.abs(r.errorPercent), 0)
              / historyLog.value.length * 100
  return (100 - mape).toFixed(2) + '%'
})

// Helpers for SVG Chart
const chartMin = computed(() => {
  if (historyLog.value.length === 0) return 0
  const prices = historyLog.value.map(p => p.price)
  const predicted = historyLog.value.map(p => p.predicted)
  return Math.min(...prices, ...predicted) * 0.99
})

const chartMax = computed(() => {
  if (historyLog.value.length === 0) return 0
  const prices = historyLog.value.map(p => p.price)
  const predicted = historyLog.value.map(p => p.predicted)
  return Math.max(...prices, ...predicted) * 1.01
})

const chartMid = computed(() => {
  return (chartMin.value + chartMax.value) / 2
})

const getX = (index, total) => {
  if (total <= 1) return 0
  return (index / (total - 1)) * 100
}

const getY = (price) => {
  const min = chartMin.value
  const max = chartMax.value
  if (max === min) return 50
  return 100 - (((price - min) / (max - min)) * 100)
}

const chronologicalData = computed(() => {
  return [...historyLog.value].reverse()
})

const actualPath = computed(() => {
  const data = chronologicalData.value
  if (data.length === 0) return ''
  return data.map((d, i) => {
    const x = getX(i, data.length)
    const y = getY(d.price)
    return `${i === 0 ? 'M' : 'L'} ${x} ${y}`
  }).join(' ')
})

const predictedPath = computed(() => {
  const data = chronologicalData.value
  if (data.length === 0) return ''
  return data.map((d, i) => {
    const x = getX(i, data.length)
    const y = getY(d.predicted)
    return `${i === 0 ? 'M' : 'L'} ${x} ${y}`
  }).join(' ')
})

const startDateLabel = computed(() => {
  const data = chronologicalData.value
  if (data.length === 0) return ''
  return data[0].date
})

const endDateLabel = computed(() => {
  const data = chronologicalData.value
  if (data.length === 0) return ''
  return data[data.length - 1].date
})

const formatPrice = (value) => {
  if (!value) return 'Rp 0'
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0
  }).format(value)
}

const formatK = (value) => {
  if (!value) return '0'
  return (value / 1000).toFixed(1) + 'k'
}

// CSV Export
const exportToCSV = () => {
  if (historyLog.value.length === 0) return
  let csvContent = "data:text/csv;charset=utf-8," 
    + "Date,Commodity,Actual Price,Predicted Price,Delta\n"
  
  historyLog.value.forEach(row => {
    csvContent += `${row.date},${selectedCommodity.value},${row.price},${row.predicted},${row.delta.toFixed(2)}%\n`
  })
  
  const encodedUri = encodeURI(csvContent)
  const link = document.createElement("a")
  link.setAttribute("href", encodedUri)
  link.setAttribute("download", `harga_historis_${selectedCommodity.value.replace(/\s+/g, '_').toLowerCase()}.csv`)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// Watchers
watch([selectedCommodity, timeRange], () => {
  fetchHistory()
})

onMounted(() => {
  fetchCommodities().then(() => {
    fetchHistory()
  })
})
</script>
