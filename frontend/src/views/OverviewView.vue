<template>
  <div class="space-y-xl">
    <!-- Header -->
    <header class="flex flex-col md:flex-row justify-between items-start md:items-center gap-md">
      <div>
        <h2 class="font-display-lg text-display-lg text-on-surface mb-base">Market Overview</h2>
        <p class="font-body-lg text-body-lg text-on-surface-variant">Real-time commodity pricing and analytics.</p>
      </div>
      <div class="relative w-full md:w-64">
        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline-variant text-[20px]">search</span>
        <input v-model="searchQuery" class="w-full bg-surface-container-low/50 border-b border-outline-variant text-on-surface font-body-sm text-body-sm pl-10 pr-sm py-sm focus:outline-none focus:border-[#00E5FF] focus:shadow-[inset_0_-2px_10px_rgba(0,229,255,0.1)] transition-all bg-transparent placeholder-on-surface-variant rounded-t-DEFAULT" placeholder="Search commodities..." type="text"/>
      </div>
    </header>

    <!-- Top Movers (Bento Grid) -->
    <section>
      <h3 class="font-headline-lg text-headline-lg text-on-surface mb-md">Top Movers (24h)</h3>
      <div v-if="isLoading" class="text-on-surface-variant font-data-mono">Loading market data...</div>
      <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-gutter">
        <div v-for="mover in topMovers" :key="mover.name" class="glass-card rounded-xl p-md flex flex-col justify-between h-48 relative overflow-hidden group">
          <div class="absolute inset-0 bg-gradient-to-b from-[#00E5FF]/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          <div class="flex justify-between items-start relative z-10">
            <div>
              <span class="font-label-caps text-label-caps text-on-surface-variant uppercase tracking-wider block mb-xs">{{ mover.category }}</span>
              <h4 class="font-title-md text-title-md text-on-surface font-bold">{{ mover.name }}</h4>
            </div>
            <div :class="mover.change_percentage > 0 ? 'bg-error/10 text-error' : (mover.change_percentage < 0 ? 'bg-[#00E5FF]/10 text-cyan' : 'bg-surface-variant text-on-surface-variant')" class="flex items-center gap-xs px-sm py-xs rounded-full">
              <span class="material-symbols-outlined text-[16px]">
                  {{ mover.change_percentage > 0 ? 'trending_up' : (mover.change_percentage < 0 ? 'trending_down' : 'remove') }}
              </span>
              <span class="font-data-mono text-data-mono text-sm">{{ mover.change_percentage > 0 ? '+' : '' }}{{ mover.change_percentage }}%</span>
            </div>
          </div>
          <div class="relative z-10">
            <p class="font-data-mono text-data-mono text-[32px] text-on-surface font-bold">{{ formatPrice(mover.latest_price) }}<span class="text-body-sm text-on-surface-variant font-normal ml-xs">/kg</span></p>
          </div>
        </div>
      </div>
    </section>

    <!-- Main Commodity Grid -->
    <section>
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-lg gap-md">
        <h3 class="font-headline-lg text-headline-lg text-on-surface">All Commodities</h3>
        <div class="flex flex-wrap gap-sm">
          <button @click="activeCategory = 'All'" :class="activeCategory === 'All' ? 'border-cyan text-cyan shadow-[0_0_8px_rgba(0,229,255,0.2)]' : 'border-transparent text-on-surface-variant hover:text-on-surface'" class="px-md py-sm rounded-full glass-card font-label-caps text-label-caps transition-colors">All</button>
          <button @click="activeCategory = 'Grains'" :class="activeCategory === 'Grains' ? 'border-cyan text-cyan shadow-[0_0_8px_rgba(0,229,255,0.2)]' : 'border-transparent text-on-surface-variant hover:text-on-surface'" class="px-md py-sm rounded-full glass-card font-label-caps text-label-caps transition-colors">Grains</button>
          <button @click="activeCategory = 'Spices'" :class="activeCategory === 'Spices' ? 'border-cyan text-cyan shadow-[0_0_8px_rgba(0,229,255,0.2)]' : 'border-transparent text-on-surface-variant hover:text-on-surface'" class="px-md py-sm rounded-full glass-card font-label-caps text-label-caps transition-colors">Spices</button>
          <button @click="activeCategory = 'Meat'" :class="activeCategory === 'Meat' ? 'border-cyan text-cyan shadow-[0_0_8px_rgba(0,229,255,0.2)]' : 'border-transparent text-on-surface-variant hover:text-on-surface'" class="px-md py-sm rounded-full glass-card font-label-caps text-label-caps transition-colors">Meat</button>
          <button @click="activeCategory = 'Groceries'" :class="activeCategory === 'Groceries' ? 'border-cyan text-cyan shadow-[0_0_8px_rgba(0,229,255,0.2)]' : 'border-transparent text-on-surface-variant hover:text-on-surface'" class="px-md py-sm rounded-full glass-card font-label-caps text-label-caps transition-colors">Groceries</button>
        </div>
      </div>
      
      <div v-if="isLoading" class="text-on-surface-variant font-data-mono">Loading commodities...</div>
      <div v-else-if="filteredCommodities.length === 0" class="text-on-surface-variant font-data-mono">No commodities found.</div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-gutter">
        <div v-for="item in filteredCommodities" :key="item.name" @click="openModal(item)" class="glass-card rounded-lg p-md hover:border-cyan/50 transition-colors duration-300 cursor-pointer">
          <div class="flex justify-between items-start mb-md">
            <h5 class="font-title-md text-title-md text-on-surface font-semibold mr-2 leading-tight" :title="item.name">{{ item.name }}</h5>
            <span class="font-label-caps text-label-caps text-on-surface-variant bg-white/5 px-sm py-xs rounded whitespace-nowrap">{{ item.category }}</span>
          </div>
          <div class="flex justify-between items-end mb-sm">
            <p class="font-data-mono text-data-mono text-[20px] text-on-surface">{{ formatPrice(item.latest_price) }}</p>
            <span :class="item.change_percentage > 0 ? 'text-error' : (item.change_percentage < 0 ? 'text-cyan' : 'text-on-surface-variant')" class="text-sm font-data-mono">
                {{ item.change_percentage > 0 ? '+' : '' }}{{ item.change_percentage }}%
            </span>
          </div>
        </div>
      </div>
    </section>

    <!-- Modal Line Chart -->
    <Teleport to="body">
      <div v-if="selectedItem" class="fixed inset-0 z-[100] flex items-center justify-center p-md">
        <!-- Backdrop -->
        <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="closeModal"></div>
        
        <!-- Modal Content -->
        <div class="relative glass-panel rounded-xl p-lg w-full max-w-3xl flex flex-col gap-md shadow-2xl border border-white/10 animate-in fade-in zoom-in duration-300">
          <div class="flex justify-between items-start">
            <div>
              <h3 class="text-2xl font-bold text-on-surface leading-tight pr-8">{{ selectedItem.name }}</h3>
              <p class="text-on-surface-variant font-data-mono mt-1">Price History (Monthly, {{ selectedYearFilter === 'All' ? '2021 - Sekarang' : selectedYearFilter }})</p>
            </div>
            <button @click="closeModal" class="material-symbols-outlined text-on-surface-variant hover:text-white transition-colors absolute top-md right-md bg-white/5 rounded-full p-2">close</button>
          </div>

          <!-- Year Filter Tabs -->
          <div class="flex flex-wrap gap-xs bg-white/5 p-1 rounded-lg border border-white/5 w-fit">
            <button v-for="year in ['All', '2021', '2022', '2023', '2024', '2025', '2026']"
                    :key="year"
                    @click="selectYearFilter(year)"
                    :class="selectedYearFilter === year ? 'bg-cyan/20 text-cyan border-cyan/30 shadow-[0_0_8px_rgba(0,229,255,0.15)]' : 'border-transparent text-on-surface-variant hover:bg-white/5 hover:text-on-surface'"
                    class="px-sm py-1.5 rounded-md text-xs font-semibold border transition-all duration-200">
              {{ year }}
            </button>
          </div>
          
          <div class="h-64 relative mt-sm w-full border-b border-l border-white/10 pb-md pl-md flex items-end">
            <!-- Y-Axis Labels -->
            <div v-if="!isModalLoading" class="absolute left-0 top-0 h-full flex flex-col justify-between text-on-surface-variant font-label-caps text-label-caps -ml-16 py-2 w-14 text-right">
              <span>{{ formatK(modalChartMax) }}</span>
              <span>{{ formatK(modalChartMin) }}</span>
            </div>

            <!-- Grid Lines -->
            <div class="absolute inset-0 ml-md mb-md flex flex-col justify-between pointer-events-none">
              <div class="w-full h-px bg-white/5"></div>
              <div class="w-full h-px bg-white/5"></div>
            </div>

            <div v-if="isModalLoading" class="absolute inset-0 flex items-center justify-center font-data-mono text-on-surface-variant z-10">
              Loading history...
            </div>
            <div v-else-if="itemHistory.length === 0" class="absolute inset-0 flex items-center justify-center font-data-mono text-on-surface-variant z-10">
              No historical data.
            </div>
            <div v-else class="w-full h-full relative z-10 py-4 px-2">
              <div class="w-full h-full relative">
                <!-- SVG Chart -->
                <svg viewBox="0 0 100 100" class="absolute inset-0 w-full h-full overflow-visible pointer-events-none" preserveAspectRatio="none">
                  <path :d="modalChartPath" fill="none" stroke="#00E5FF" stroke-width="3" filter="drop-shadow(0px 0px 4px rgba(0,229,255,0.6))" vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round"></path>
              </svg>

              <!-- Points -->
              <div v-for="(pt, i) in itemHistory" :key="i"
                   class="absolute w-6 h-6 -ml-3 -mt-3 rounded-full cursor-pointer z-20 group flex items-center justify-center"
                   :style="{ left: `${getModalX(i)}%`, top: `${getModalY(pt.price)}%` }">
                   <!-- Tooltip -->
                   <div class="absolute bottom-full mb-1 bg-black/80 backdrop-blur-md text-white text-[12px] px-sm py-xs rounded border border-white/10 opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none text-center shadow-xl z-30">
                       <span class="text-xs text-cyan block mb-1">Bulan: {{ formatMonth(pt.date) }}</span>
                       <strong class="font-data-mono text-sm">{{ formatPrice(pt.price) }}</strong>
                   </div>
                   <!-- Indicator -->
                   <div class="w-2.5 h-2.5 bg-cyan rounded-full shadow-[0_0_8px_#00E5FF] transition-transform group-hover:scale-150"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const commodities = ref([])
const isLoading = ref(true)
const searchQuery = ref('')
const activeCategory = ref('All')

// Modal State
const selectedItem = ref(null)
const itemHistory = ref([])
const isModalLoading = ref(false)
const selectedYearFilter = ref('All')

const formatPrice = (value) => {
  if (!value && value !== 0) return 'Rp 0'
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

const fetchOverview = async () => {
    isLoading.value = true
    try {
        const res = await api.get('/overview')
        commodities.value = res.data
    } catch (error) {
        console.error("Failed to fetch overview data", error)
    } finally {
        isLoading.value = false
    }
}

const topMovers = computed(() => {
    if (commodities.value.length === 0) return []
    return [...commodities.value]
        .sort((a, b) => Math.abs(b.change_percentage) - Math.abs(a.change_percentage))
        .slice(0, 3)
})

const filteredCommodities = computed(() => {
    let result = commodities.value
    
    if (activeCategory.value !== 'All') {
        result = result.filter(c => c.category === activeCategory.value)
    }
    
    if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        result = result.filter(c => c.name.toLowerCase().includes(query))
    }
    
    return result
})

const formatMonth = (dateStr) => {
  if (!dateStr) return ''
  const [year, month] = dateStr.split('-')
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ]
  const mIndex = parseInt(month, 10) - 1
  return `${months[mIndex]} ${year}`
}

// Modal Actions
const fetchModalHistory = async () => {
    if (!selectedItem.value) return
    isModalLoading.value = true
    try {
        const params = {
            subcategory: selectedItem.value.name,
            monthly: true
        }
        if (selectedYearFilter.value === 'All') {
            params.start_year = 2021
            params.end_year = 2026
        } else {
            const yr = parseInt(selectedYearFilter.value, 10)
            params.start_year = yr
            params.end_year = yr
        }
        const res = await api.get('/historical', { params })
        itemHistory.value = res.data
    } catch (err) {
        console.error("Failed to load history for modal", err)
    } finally {
        isModalLoading.value = false
    }
}

const openModal = async (item) => {
    selectedItem.value = item
    selectedYearFilter.value = 'All'
    await fetchModalHistory()
}

const selectYearFilter = async (year) => {
    selectedYearFilter.value = year
    await fetchModalHistory()
}

const closeModal = () => {
    selectedItem.value = null
    itemHistory.value = []
    selectedYearFilter.value = 'All'
}

// Modal SVG Logic
const modalChartMin = computed(() => {
    if (!itemHistory.value.length) return 0
    return Math.min(...itemHistory.value.map(d => d.price)) * 0.99
})

const modalChartMax = computed(() => {
    if (!itemHistory.value.length) return 0
    return Math.max(...itemHistory.value.map(d => d.price)) * 1.01
})

const getModalX = (index) => {
    const total = itemHistory.value.length
    if (total <= 1) return 0
    return (index / (total - 1)) * 100
}

const getModalY = (price) => {
    const min = modalChartMin.value
    const max = modalChartMax.value
    if (max === min) return 50
    return 100 - (((price - min) / (max - min)) * 100)
}

const modalChartPath = computed(() => {
    if (itemHistory.value.length === 0) return ''
    return itemHistory.value.map((d, i) => {
        return `${i === 0 ? 'M' : 'L'} ${getModalX(i)} ${getModalY(d.price)}`
    }).join(' ')
})

onMounted(() => {
    fetchOverview()
})
</script>
