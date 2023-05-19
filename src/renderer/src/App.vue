<template>
    <div class="mt-1 me-1 text-right">
        <Button type="button" severity="secondary" icon="pi pi-cog" rounded class="options-button" @click="toggleOptionsOverlay" />
    </div>
    <div class="card-wrap">
        <tem-card :tem="tem2" :label="'Left'"></tem-card>
        <tem-card :tem="tem1" :label="'Right'"></tem-card>
    </div>
    <data-file-indicator></data-file-indicator>
    <tem-history></tem-history>
    <OverlayPanel ref="optionsOverlayRef" class="settings-popover">
        <div class="settings-wrap">
            <b-form-checkbox v-model="settingsStore.showAnimatedTemGifs" size="sm">Animated GIFs</b-form-checkbox>
            <b-form-checkbox v-model="settingsStore.showTypeLabels" size="sm">Type labels</b-form-checkbox>
        </div>
    </OverlayPanel>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import { storeToRefs } from 'pinia';
import axios from 'axios';
import OverlayPanel from 'primevue/overlaypanel';
import Button from 'primevue/button';

import { useSettingsStore } from '@/store/settings';
import { useTemStore } from '@/store/tem';
import temCard from './components/temCard.vue';
import temHistory from './components/temHistory.vue';
import dataFileIndicator from './components/dataFileIndicator.vue';

const REFRESH_INTERVAL_SECONDS = 1;

const settingsStore = useSettingsStore();

const temStore = useTemStore();
const { tem1, tem2 } = storeToRefs(temStore);
const optionsOverlayRef = ref();

/**
 * Lifecycle hooks
 */
onMounted(() => {
    loadTemtemApiData();
});

/**
 * Utility functions
 */
async function loadTemtemApiData() {
    const temtems = await axios.get('https://temtem-api.mael.tech/api/temtems');
    const traits = await axios.get('https://temtem-api.mael.tech/api/traits');
    try {
        temStore.setTemApiData(temtems.data);
        temStore.setTraitApiData(traits.data);
    } catch (e) {
        console.error(e);
    }
    loadDataLoop();
}

async function loadDataLoop() {
    const response = await axios
        .get('/temdata.json')
        .then(data => {
            temStore.isJsonFileAvailable = true;
            return data;
        })
        .catch(() => {
            temStore.isJsonFileAvailable = false;
        })
        .finally(() => {
            temStore.hasAttemptedJsonFileLoad = true;
        });

    try {
        temStore.setTemParseData({ jsonData: response.data });
    } catch (e) {
        console.error(`[loadDataLoop] unable to load JSON data`, { error: e });
    }

    setTimeout(loadDataLoop, REFRESH_INTERVAL_SECONDS * 1000);
}

const toggleOptionsOverlay = event => {
    optionsOverlayRef.value.toggle(event);
};
</script>

<style lang="scss">
.settings-popover .p-overlaypanel-content {
    padding: 0.75rem 1rem;
}
</style>

<style scoped lang="scss">
.options-button {
    opacity: 0.75;
    transition: opacity 0.2s ease-in-out;
    &:hover {
        opacity: 1;
    }
}
.settings-wrap {
    text-align: left;
    width: 8rem;
    margin: 0 auto;

    .form-check {
        margin-bottom: -0.2rem;
        font-size: 0.8rem;
    }
}
.card-wrap {
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
    justify-content: center;
    align-items: start;
    width: 100%;
    height: 100%;
}
</style>
