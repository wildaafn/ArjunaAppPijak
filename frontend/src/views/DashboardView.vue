<template>
  <div class="flex flex-col">
    <!-- Header -->
    <header class="mb-lg">
      <h2 class="font-display-lg text-display-lg text-on-surface mb-xs">Analisis Harga & Tinjauan Pangan Nusantara</h2>
      <p class="font-body-lg text-body-lg text-on-surface-variant max-w-2xl">
        Advanced AI-driven forecasting for staple commodities across regions. Adjust parameters to visualize future market stability.
      </p>
    </header>

    <!-- Main Layout Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-gutter">
      <!-- Left Column: Control Panel (4 cols) -->
      <div class="lg:col-span-4 flex flex-col gap-md h-full">
        <!-- Controls Card -->
        <div class="glass-panel rounded-xl p-md flex flex-col gap-md">
          <div>
            <h3 class="font-title-md text-title-md text-primary mb-md flex items-center gap-xs">
              <span class="material-symbols-outlined text-cyan text-[20px]">tune</span>
              Forecast Parameters
            </h3>
            
            <!-- Dropdown -->
            <div class="flex flex-col gap-xs mb-md">
              <label class="font-label-caps text-label-caps text-on-surface-variant">Commodity</label>
              <div class="relative">
                <select v-model="selectedCommodity" class="w-full bg-white/5 border border-white/10 rounded-lg py-sm px-md text-on-surface font-body-sm text-body-sm appearance-none focus:outline-none focus:border-cyan transition-colors">
                  <option v-for="c in commodities" :key="c" :value="c" class="bg-surface text-on-surface">{{ c }}</option>
                </select>
                <span class="material-symbols-outlined absolute right-sm top-1/2 -translate-y-1/2 pointer-events-none text-on-surface-variant">arrow_drop_down</span>
              </div>
            </div>
            
            <!-- Slider -->
            <div class="flex flex-col gap-sm">
              <div class="flex justify-between items-end">
                <label class="font-label-caps text-label-caps text-on-surface-variant">Prediction Horizon</label>
                <span class="font-data-mono text-data-mono text-cyan" id="horizon-val">{{ horizon }} Days</span>
              </div>
              <input class="w-full" max="7" min="1" type="range" v-model="horizon" />
            </div>
          </div>
          
          <!-- Action -->
          <button @click="fetchData" :disabled="isLoading || isAiLoading" class="w-full py-sm px-lg bg-secondary-container text-on-secondary-container font-headline-lg-mobile text-headline-lg-mobile font-bold rounded-lg shadow-lg hover:brightness-110 active:scale-95 transition-all mt-xs disabled:opacity-50 disabled:pointer-events-none">
            {{ isLoading || isAiLoading ? 'Processing...' : 'Generate Forecast' }}
          </button>
        </div>
        
        <!-- AI Smart Card -->
        <div class="glass-panel-elevated rounded-xl p-md border-l-4 border-l-cyan flex-1 flex flex-col gap-md">
          <div>
            <h3 class="font-title-md text-title-md text-primary mb-md flex items-center gap-xs">
              <span class="material-symbols-outlined text-cyan text-[20px]">auto_awesome</span>
              AI Insight
            </h3>
            <div class="min-h-[60px]">
              <span v-if="isLoading || isAiLoading" class="flex items-center gap-sm font-body-sm text-body-sm text-on-surface-variant">
                <span class="w-4 h-4 border-2 border-cyan border-t-transparent rounded-full animate-spin"></span>
                Generating business analysis insight...
              </span>
              <span v-else-if="error || aiInsightError" class="text-error font-body-sm text-body-sm">
                {{ error || aiInsightError }}
              </span>
              <div v-else-if="aiInsight" class="flex flex-col gap-md">
                <!-- Perspektif Masyarakat -->
                <div class="flex flex-col gap-xs">
                  <div class="flex items-center gap-xs text-[11px] font-bold text-cyan uppercase tracking-wider">
                    <span class="material-symbols-outlined text-[16px]">shopping_bag</span>
                    Masyarakat / Konsumen
                  </div>
                  <p class="text-on-surface leading-relaxed font-body-sm text-body-sm">
                    {{ aiInsight.masyarakat }}
                  </p>
                </div>
                
                <!-- Divider -->
                <div class="h-px bg-white/5"></div>
                
                <!-- Perspektif Pedagang -->
                <div class="flex flex-col gap-xs">
                  <div class="flex items-center gap-xs text-[11px] font-bold text-emerald-400 uppercase tracking-wider">
                    <span class="material-symbols-outlined text-[16px]">storefront</span>
                    Pelaku Usaha / Pedagang
                  </div>
                  <p class="text-on-surface leading-relaxed font-body-sm text-body-sm">
                    {{ aiInsight.pedagang }}
                  </p>
                </div>
                
                <!-- Disclaimer -->
                <div v-if="aiInsight.disclaimer" class="text-[10px] text-on-surface-variant font-light italic mt-xs">
                  {{ aiInsight.disclaimer }}
                </div>
              </div>
            </div>
          </div>
          
          <div class="mt-auto pt-md border-t border-white/10 flex items-center justify-between">
            <div class="flex items-center gap-xs">
              <div class="w-1.5 h-1.5 rounded-full bg-cyan animate-pulse"></div>
              <span class="text-[10px] font-label-caps text-on-surface-variant uppercase tracking-wider">Model Status</span>
            </div>
            <span class="text-xs font-data-mono text-cyan">Active / SARIMAX</span>
          </div>
        </div>
      </div>

      <!-- Right Column: Visualizations (8 cols) -->
      <div class="lg:col-span-8 flex flex-col gap-md">
        <!-- Summary KPI Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-sm">
          <div class="glass-panel rounded-xl p-md flex flex-col justify-between">
            <span class="font-label-caps text-label-caps text-on-surface-variant mb-sm block">Last Historical Price</span>
            <div class="text-2xl font-bold font-data-mono text-on-surface">{{ formatPrice(lastHistoricalPrice) }}<span class="text-sm font-normal text-on-surface-variant ml-1">/kg</span></div>
          </div>
          <div class="glass-panel rounded-xl p-md flex flex-col justify-between border-b-2 border-b-cyan">
            <span class="font-label-caps text-label-caps text-on-surface-variant mb-sm block">Predicted (Day+{{ horizon }})</span>
            <div class="text-2xl font-bold font-data-mono text-cyan">{{ formatPrice(lastPredictedPrice) }}<span class="text-sm font-normal text-on-surface-variant ml-1">/kg</span></div>
          </div>
          <div class="glass-panel rounded-xl p-md flex flex-col justify-between">
            <span class="font-label-caps text-label-caps text-on-surface-variant mb-sm block">Forecast Trend</span>
            <div class="flex items-center gap-sm">
              <span :class="trendPercentage > 0 ? 'text-error' : 'text-primary'" class="material-symbols-outlined text-3xl">
                {{ trendPercentage > 0 ? 'trending_up' : 'trending_down' }}
              </span>
              <span :class="trendPercentage > 0 ? 'text-error' : 'text-primary'" class="text-2xl font-bold">
                {{ trendPercentage > 0 ? 'Upward' : 'Downward' }}
              </span>
            </div>
          </div>
        </div>

        <!-- Main Chart Area -->
        <div class="glass-panel rounded-xl p-md flex-1 min-h-[400px] flex flex-col">
          <div class="flex justify-between items-center mb-md">
            <h3 class="font-title-md text-title-md text-primary">Price Trajectory Simulation</h3>
            <div class="flex gap-sm">
              <div class="flex items-center gap-xs">
                <div class="w-3 h-3 rounded-full bg-white/30"></div>
                <span class="font-label-caps text-label-caps text-on-surface-variant">Historical</span>
              </div>
              <div class="flex items-center gap-xs">
                <div class="w-3 h-3 rounded-full bg-cyan cyan-glow"></div>
                <span class="font-label-caps text-label-caps text-on-surface-variant">Prediction</span>
              </div>
            </div>
          </div>

          <!-- Dynamic Line Chart -->
          <div class="relative flex-1 mt-lg ml-16 mr-4 mb-6 border-b border-l border-white/10 flex items-end">
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

            <!-- Data Chart -->
            <div v-if="isLoading" class="absolute inset-0 flex items-center justify-center text-on-surface-variant font-data-mono z-10">
                Loading forecast data...
            </div>
            <div v-else-if="error" class="absolute inset-0 flex items-center justify-center text-error font-data-mono z-10">
                {{ error }}
            </div>
            <div v-else class="w-full h-full relative z-10 py-4 px-2">
              <div class="w-full h-full relative">
                <!-- SVG Line Chart -->
                <svg viewBox="0 0 100 100" class="absolute inset-0 w-full h-full overflow-visible pointer-events-none" preserveAspectRatio="none">
                    <!-- Historical Line -->
                    <path :d="historicalPath" fill="none" stroke="rgba(255,255,255,0.4)" stroke-dasharray="2,2" stroke-width="2" vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round"></path>
                    <!-- Prediction Line -->
                    <path :d="predictionPath" fill="none" stroke="#00E5FF" stroke-width="3" filter="drop-shadow(0px 0px 4px rgba(0,229,255,0.6))" vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>

                <!-- Interactive Points -->
                <div v-for="(item, index) in chartData" :key="index" 
                    class="absolute w-6 h-6 -ml-3 -mt-3 rounded-full cursor-pointer z-20 group flex items-center justify-center" 
                    :style="{ left: `${getX(index, chartData.length)}%`, top: `${getY(item.price)}%` }">
                    
                    <!-- Tooltip -->
                    <div class="absolute bottom-full mb-1 bg-black/80 backdrop-blur-md text-white text-[12px] px-sm py-xs rounded border border-white/10 opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none text-center shadow-xl z-30">
                        <span class="text-xs text-white/60 block">{{ item.date }}</span>
                        <strong>{{ formatPrice(item.price) }}</strong>
                        <span class="text-[10px] text-white/50 block mt-1">{{ item.isHistorical ? 'Historical' : 'Prediction' }}</span>
                    </div>
                    
                    <!-- Point Indicator -->
                    <div class="w-2.5 h-2.5 rounded-full transition-transform group-hover:scale-150" 
                        :class="item.isHistorical ? 'bg-white/70' : 'bg-cyan shadow-[0_0_8px_#00E5FF]'"></div>
                </div>
              </div>
            </div>

            <!-- X-Axis Labels -->
            <div class="absolute bottom-0 left-0 w-full flex justify-between text-on-surface-variant font-label-caps text-label-caps -mb-6 px-2">
              <span>-14d</span>
              <span>Today</span>
              <span>+{{ horizon }}d</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import api from '@/services/api'

const commodities = ref([])
const selectedCommodity = ref('Beras Kualitas Medium I')
const horizon = ref(7)
const lastHistoricalPrice = ref(0)
const predictions = ref([])
const historicalData = ref([])
const isLoading = ref(true)
const error = ref(null)

const aiInsight = ref(null)
const isAiLoading = ref(false)
const aiInsightError = ref(null)

const fetchCommodities = async () => {
    try {
        const res = await api.get('/commodities')
        commodities.value = res.data
        if (commodities.value.length > 0 && !commodities.value.includes(selectedCommodity.value)) {
            selectedCommodity.value = commodities.value[0]
        }
        fetchData()
    } catch (err) {
        console.error("Failed to fetch commodities", err)
    }
}

const lastPredictedPrice = computed(() => {
    if (predictions.value.length === 0) return 0
    return predictions.value[predictions.value.length - 1].predicted_price
})

const trendPercentage = computed(() => {
    if (!lastHistoricalPrice.value || !lastPredictedPrice.value) return 0
    const diff = lastPredictedPrice.value - lastHistoricalPrice.value
    return ((diff / lastHistoricalPrice.value) * 100).toFixed(1)
})

const chartData = computed(() => {
    const data = []
    historicalData.value.forEach(d => {
        data.push({ date: d.date, price: d.price, isHistorical: true })
    })
    predictions.value.forEach(p => {
        data.push({ date: p.date, price: p.predicted_price, isHistorical: false })
    })
    return data
})

const chartMin = computed(() => {
    if (chartData.value.length === 0) return 0
    const prices = chartData.value.map(p => p.price)
    return Math.min(...prices) * 0.99
})

const chartMax = computed(() => {
    if (chartData.value.length === 0) return 0
    const prices = chartData.value.map(p => p.price)
    return Math.max(...prices) * 1.01
})

const chartMid = computed(() => {
    return (chartMin.value + chartMax.value) / 2
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

const historicalPath = computed(() => {
    if (historicalData.value.length === 0) return ''
    const total = chartData.value.length
    return historicalData.value.map((d, i) => {
        const x = getX(i, total)
        const y = getY(d.price)
        return `${i === 0 ? 'M' : 'L'} ${x} ${y}`
    }).join(' ')
})

const predictionPath = computed(() => {
    if (predictions.value.length === 0) return ''
    const histLen = historicalData.value.length
    const total = chartData.value.length
    
    let path = ''
    if (histLen > 0) {
        const lastHist = historicalData.value[histLen - 1]
        const startX = getX(histLen - 1, total)
        const startY = getY(lastHist.price)
        path += `M ${startX} ${startY} `
    }
    
    const predPart = predictions.value.map((d, i) => {
        const index = histLen + i
        const x = getX(index, total)
        const y = getY(d.predicted_price)
        return `${path === '' && i === 0 ? 'M' : 'L'} ${x} ${y}`
    }).join(' ')
    
    return path + predPart
})

const fetchAiInsight = async () => {
    isAiLoading.value = true
    aiInsightError.value = null
    try {
        const res = await api.get('/insight', {
            params: {
                subcategory: selectedCommodity.value,
                trend: trendPercentage.value,
                horizon: horizon.value,
                current_price: lastHistoricalPrice.value,
                predicted_price: lastPredictedPrice.value
            }
        })
        aiInsight.value = res.data.insight
    } catch (err) {
        console.error('AI Insight Error:', err)
        aiInsightError.value = 'Gagal memuat rekomendasi AI'
    } finally {
        isAiLoading.value = false
    }
}

const fetchData = async () => {
    isLoading.value = true
    error.value = null
    aiInsight.value = null
    aiInsightError.value = null
    try {
        const [predictRes, histRes] = await Promise.all([
            api.get('/predict', {
                params: {
                    subcategory: selectedCommodity.value,
                    model_type: 'sarimax',
                    steps: horizon.value
                }
            }),
            api.get('/historical', {
                params: {
                    subcategory: selectedCommodity.value,
                    days: 14 // Get last 14 days of historical data for chart context
                }
            })
        ])
        
        lastHistoricalPrice.value = predictRes.data.last_historical_price
        predictions.value = predictRes.data.predictions
        historicalData.value = histRes.data
        
        // Fetch AI Insight asynchronously in the background
        fetchAiInsight()
    } catch (err) {
        console.error('API Error:', err)
        error.value = 'Gagal memuat data prediksi'
    } finally {
        isLoading.value = false
    }
}

onMounted(() => {
    fetchCommodities()
})
</script>
