<template>
  <div class="text-on-surface antialiased min-h-screen flex overflow-hidden">
    <MobileNav />
    <Sidebar />
    <main class="flex-1 md:ml-64 pt-20 md:pt-lg px-md md:px-lg pb-xl min-h-screen overflow-y-auto relative">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import Sidebar from '@/components/Navigation/Sidebar.vue'
import MobileNav from '@/components/Navigation/MobileNav.vue'
</script>
