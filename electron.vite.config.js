import { resolve } from 'path';
import { defineConfig, externalizeDepsPlugin } from 'electron-vite';
import vue from '@vitejs/plugin-vue';
import Components from 'unplugin-vue-components/vite';
import { BootstrapVueNextResolver } from 'unplugin-vue-components/resolvers';
import eslintPlugin from 'vite-plugin-eslint';

export default defineConfig({
    main: {
        plugins: [externalizeDepsPlugin()],
    },
    preload: {
        plugins: [externalizeDepsPlugin()],
    },
    renderer: {
        publicDir: resolve(__dirname, 'src/renderer/public'),
        resolve: {
            alias: {
                '@': resolve('src/renderer/src'),
                '~': resolve(__dirname, 'node_modules'),
            },
        },
        plugins: [
            vue(),
            Components({
                resolvers: [BootstrapVueNextResolver()],
            }),
            eslintPlugin(),
        ],
    },
});
