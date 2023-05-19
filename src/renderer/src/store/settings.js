import { defineStore } from 'pinia';
import { useStorage } from '@vueuse/core';

export const useSettingsStore = defineStore('settings', {
    state: () => {
        return {
            showAnimatedTemGifs: useStorage('settings/showAnimatedTemGifs', false),
            showTypeLabels: useStorage('settings/showTypeLabels', false),
        };
    },

    getters: {},

    actions: {},
});
