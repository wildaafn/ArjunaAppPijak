<template>
  <nav class="hidden md:flex flex-col p-md gap-sm fixed left-0 top-0 h-full w-64 z-40 bg-white/10 backdrop-blur-xl border-r border-white/10 transition-all duration-300 ease-in-out">
    <!-- Header -->
    <div class="flex items-center gap-sm mb-lg px-sm">
      <img src="@/assets/arjuna-logo.png" alt="Logo" class="w-10 h-10 object-contain rounded-lg shrink-0 bg-white p-1" />
      <div class="flex flex-col">
        <span class="font-headline-lg text-[20px] font-bold text-on-surface leading-tight">Arjuna Pijak</span>
        <span class="font-label-caps text-label-caps text-on-surface-variant">Price Intelligence</span>
      </div>
    </div>

    <!-- Main Tabs -->
    <div class="flex flex-col gap-xs flex-1">
      <router-link to="/" class="flex items-center gap-sm px-md py-sm rounded-lg transition-all" :class="[isActive('/') ? 'bg-secondary-container text-on-secondary-container font-bold shadow-[0_0_12px_rgba(250,189,0,0.3)]' : 'text-on-surface-variant hover:bg-white/5 hover:text-primary']">
        <span class="material-symbols-outlined text-[20px]">dashboard</span>
        <span class="font-label-caps text-label-caps">Dashboard</span>
      </router-link>

      <router-link to="/overview" class="flex items-center gap-sm px-md py-sm rounded-lg transition-all" :class="[isActive('/overview') ? 'bg-secondary-container text-on-secondary-container font-bold shadow-[0_0_12px_rgba(250,189,0,0.3)]' : 'text-on-surface-variant hover:bg-white/5 hover:text-primary']">
        <span class="material-symbols-outlined text-[20px]">dataset</span>
        <span class="font-label-caps text-label-caps">Overview</span>
      </router-link>

      <router-link to="/history" class="flex items-center gap-sm px-md py-sm rounded-lg transition-all" :class="[isActive('/history') ? 'bg-secondary-container text-on-secondary-container font-bold shadow-[0_0_12px_rgba(250,189,0,0.3)]' : 'text-on-surface-variant hover:bg-white/5 hover:text-primary']">
        <span class="material-symbols-outlined text-[20px]">history</span>
        <span class="font-label-caps text-label-caps">History</span>
      </router-link>
    </div>
  </nav>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()
const isActive = (path) => route.path === path
</script>
