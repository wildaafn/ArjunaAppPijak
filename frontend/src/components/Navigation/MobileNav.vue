<template>
  <nav class="md:hidden fixed top-0 left-0 w-full z-50 flex justify-between items-center px-lg py-sm backdrop-blur-md bg-white/10 border-b border-white/10">
    <div class="flex items-center gap-2">
      <img src="@/assets/arjuna-logo.png" alt="Logo" class="w-8 h-8 object-contain rounded bg-white" />
      <div class="font-headline-lg-mobile text-headline-lg-mobile font-bold text-on-surface tracking-tight">Arjuna Pijak</div>
    </div>
    <div class="flex items-center gap-md">
      <router-link to="/" class="material-symbols-outlined text-primary hover:text-primary transition-colors duration-200">dashboard</router-link>
      <router-link to="/overview" class="material-symbols-outlined text-primary hover:text-primary transition-colors duration-200">dataset</router-link>
      <router-link to="/history" class="material-symbols-outlined text-primary hover:text-primary transition-colors duration-200">history</router-link>
    </div>
  </nav>
</template>
