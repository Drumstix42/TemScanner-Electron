<template>
    <div class="temHistory">
        <!-- {{  temHistory }} -->
        <div class="d-flex align-items-center flex-wrap">
            <span class="title">Recent:</span>
            <div v-for="historyRecord in temHistory" :key="historyRecord.temKey">
                <div
                    v-b-tooltip="apiData[historyRecord.temKey]?.name"
                    class="tem-avatar-wrap my-2"
                    @click="showTemModal({ key: historyRecord.temKey, name: apiData[historyRecord.temKey]?.name })"
                >
                    <img class="tem-avatar small" :src="apiData[historyRecord.temKey]?.wikiRenderStaticUrl" />
                </div>
            </div>
        </div>

        <b-modal v-model="modal" size="md" hide-header ok-only ok-title="Close" ok-variant="secondary" scrollable @shown="onModalShown">
            <tem-card :tem="modalTem"></tem-card>
        </b-modal>
    </div>
</template>

<script setup>
import { computed, ref } from 'vue';
import { useTemStore } from '@/store/tem';

const temStore = useTemStore();
const apiData = computed(() => temStore.apiData || {});
const temHistory = computed(() => temStore.temHistory);

const modal = ref(false);
const modalTitle = ref('Modal title');
const modalTem = ref({});

const showTemModal = ({ key, name } = {}) => {
    modal.value = true;
    modalTitle.value = name;
    modalTem.value = { name: key };
};

const onModalShown = () => {
    // ensures that the Escape key will close this modal in current setup
    document.querySelector(".modal-footer button").focus();
};
</script>

<style scoped lang="scss">
.temHistory {
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
    justify-content: center;
    align-items: start;
    width: 100%;
    height: 100%;
    padding: 0.2rem 1rem;
}

.title {
    color: #999;
    font-size: 0.9rem;
}

.tem-avatar-wrap {
    cursor: pointer;
    margin: 0 0.1rem;
    border: 2px solid transparent;
    border-radius: 4px;
    min-width: 2.5rem;

    &:hover {
        border: 2px solid rgb(100, 100, 100, 0.75);
        box-shadow: inset 0 0 6px 3px rgba(60, 232, 234, 0.1);
    }
}

.tem-avatar {
    width: auto;
    height: 2.8rem;
    padding: 0.2rem 0.1rem;
}
</style>
