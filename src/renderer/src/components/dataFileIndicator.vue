<template>
    <!-- show icon depending on whether or not  `isJsonFileAvailable` is true -->
    <div class="data-file-indicator d-flex align-items-center">
        <span
            v-if="hasAttemptedJsonFileLoad && !isJsonFileAvailable"
            v-b-tooltip.bottom="'Unable to load JSON data, make sure the AHK file has been started!'"
            class="pi pi-flag-fill icon-red"
        ></span>
        <span
            v-else-if="hasAttemptedJsonFileLoad && !isJsonFileValid"
            v-b-tooltip.bottom="'JSON file not populated with data yet. First enter combat, otherwise double check the AHK file is running.'"
            class="pi pi-check"
        ></span>
        <span
            v-else-if="hasAttemptedJsonFileLoad && durationWarning"
            v-b-tooltip.bottom="
                'No JSON data is imported for >1 minute, this is normal outside of combat. Otherwise, double check the AHK file is running.'
            "
            class="pi pi-info-circle"
        ></span>
        <span v-else-if="isJsonFileAvailable" v-b-tooltip.bottom="'JSON data importing successfully'" class="pi pi-check icon-green"></span>
        <span v-else v-b-tooltip.bottom="'Loading JSON data'" class="pi pi-spin pi-spinner"></span>

        <div v-if="isJsonFileAvailable && isJsonFileValid" v-b-tooltip.right.offset300="'JSON data timestamp'" class="date-time py-1 px-2">
            {{ formattedTime }}
        </div>
    </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import { useInterval } from '@vueuse/core';
import { storeToRefs } from 'pinia';
import { useTemStore } from '@/store/tem';

const temStore = useTemStore();
const { hasAttemptedJsonFileLoad, isJsonFileAvailable, isJsonFileValid } = storeToRefs(temStore);

const secondCounter = useInterval(1 * 1000);
const durationWarning = ref(false);
const formattedTime = computed(() => new Date(temStore.jsonDateTime).toLocaleTimeString());

watch(
    secondCounter,
    () => {
        const now = new Date();
        const diff = now - new Date(temStore.jsonDateTime);
        const minutes = Math.floor(diff / 1000 / 60);
        // if the difference between now and temStore.jsonDateTime is more than 1 minute, show a warning
        if (minutes >= 1) {
            durationWarning.value = true;
        } else {
            durationWarning.value = false;
        }
    },
    { immediate: true },
);
</script>

<style scoped lang="scss">
.data-file-indicator {
    position: absolute;
    top: 0;
    left: 0;

    > span,
    div {
        opacity: 0.5;
        padding: 0.4rem 0.2rem;
        transition: opacity 0.2s ease-in-out;
        transform: translateZ(0);

        &:hover {
            opacity: 1;
        }
    }
}

.pi {
    user-select: none;
}

.icon-red {
    color: rgb(200, 0, 0);
}
.icon-yellow {
    color: rgb(200, 200, 0);
}
.icon-green {
    color: rgb(0, 142, 0);
}

.date-time {
    font-size: 0.7rem;
}
</style>
