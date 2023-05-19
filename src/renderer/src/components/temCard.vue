<!-- sfc vue file with <script setup> and <template> tags -->
<template>
    <div class="temCard">
        <div class="card-label">{{ label }}</div>
        <template v-if="temData.name">
            <div class="d-flex align-items-end justify-content-center">
                <img class="tem-avatar" :src="temImageUrl" />
                <img class="tem-avatar" :src="temLumaImageUrl" />
            </div>
            <div class="d-flex align-items-center justify-content-center my-2">
                <span class="tem-number-hash">#</span>
                <span class="tem-number">{{ temData.number }}</span>
                <a class="text-decoration-none" :href="'https://temtem.wiki.gg/index.php?search=' + temData.name" target="_blank">
                    <span class="tem-name flex-grow">{{ temData.name }}</span>
                    <span class="ps-2">🔎</span>
                </a>
            </div>

            <table class="table table-details">
                <tr>
                    <td>Type</td>
                    <td>
                        <div class="d-flex align-items-center p-0">
                            <div v-for="(type, index) in temData.types" :key="type" class="tem-types flex-shrink-0">
                                <img class="type-icon" :class="index !== 0 ? 'ps-2' : ''" :src="'/images/types/' + type + '.png'" />
                                <span class="fs-small">{{ type }}</span>
                            </div>
                            <!-- select element with options generated from `temType` -->
                            <div v-if="isTemDynamicType" class="ms-2">
                                <Dropdown
                                    v-model="selectedDynamicType"
                                    class="tem-type-select"
                                    :options="temTypeOptions"
                                    placeholder="Select type"
                                    :show-clear="!!selectedDynamicType"
                                    panel-class="tem-type-select-options"
                                >
                                    <template #value="slotProps">
                                        <div v-if="slotProps.value" class="flex align-items-center">
                                            <img class="type-icon" :src="'/images/types/' + slotProps.value.label + '.png'" />
                                            <div>{{ slotProps.value.label }}</div>
                                        </div>
                                        <span v-else>
                                            {{ slotProps.placeholder }}
                                        </span>
                                    </template>
                                    <template #option="slotProps">
                                        <div class="flex align-items-center">
                                            <img class="type-icon" :src="'/images/types/' + slotProps.option.label + '.png'" />
                                            <div>{{ slotProps.option.label }}</div>
                                        </div>
                                    </template>
                                </Dropdown>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Traits</td>
                    <td>
                        <div class="traits-wrap p-0">
                            <div v-for="(trait, index) in temData.traits" :key="trait" class="flex align-items-center lh-sm">
                                <a
                                    v-b-popover.html.hover.top="temTraitsData[temData.cleanTraits[index]]?.description"
                                    :title="temData.cleanTraits[index]"
                                    :href="'https://temtem.wiki.gg/index.php?search=' + temData.cleanTraits[index]"
                                    target="_blank"
                                >
                                    {{ trait }}
                                </a>

                                <Checkbox
                                    v-if="trait === 'Iridescence'"
                                    v-model="isIridescenceActive"
                                    title="Apply trait to resistance calculations"
                                    binary
                                    class="trait-checkbox"
                                />
                                <Checkbox
                                    v-else-if="trait === 'Pigment Inverter'"
                                    v-model="isPigmentInverterActive"
                                    title="Apply trait to attack calculations"
                                    binary
                                    class="trait-checkbox"
                                />
                            </div>
                        </div>
                    </td>
                </tr>

                <tr>
                    <td colspan="2" class="col-spacer"></td>
                </tr>

                <!-- TODO: combine duplicate code into sub-component-->
                <tr>
                    <td>Defending</td>
                    <td>
                        <div class="fit-table-cell-width">
                            <div class="d-flex align-items-center">
                                <div class="types-wrap d-flex flex-wrap align-items-center text-center">
                                    <div
                                        v-for="typeModifier in temTypeResistanceModifiers"
                                        :key="typeModifier.type"
                                        v-b-tooltip="typeModifier.type"
                                        class="type-multiplier-column d-flex flex-column"
                                    >
                                        <img class="type-icon align-self-center" :src="'/images/types/' + typeModifier.type + '.png'" />
                                        <div v-if="settingsStore.showTypeLabels" class="type-label">{{ typeModifier.type }}</div>
                                        <div class="multiplier-wrap align-self-center">
                                            <div v-if="typeModifier.modifier === 0.5" class="value-box value-bad multiplier-value">&#189;</div>
                                            <div v-else-if="typeModifier.modifier === 0.25" class="value-box value-very-bad multiplier-value">
                                                &#188;
                                            </div>
                                            <div v-else class="value-box" :class="typeModifier.modifier === 4 ? 'value-very-good' : 'value-good'">
                                                <span class="multiplier-symbol">x</span>
                                                <span class="multiplier-value">{{ typeModifier.modifier }}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center ms-2">
                                    <span class="fs-5">&#187;</span>
                                    <img class="tem-avatar small" :src="temData.wikiRenderStaticUrl" />
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Attacking</td>
                    <td>
                        <div class="fit-table-cell-width">
                            <div class="d-flex align-items-center">
                                <div class="icon-vs-wrap d-flex align-items-center">
                                    <img class="type-icon icon-vs" :src="'/images/types/' + temData.types[0] + '.png'" />
                                    <span class="fs-5">&#187;</span>
                                </div>
                                <div class="types-wrap d-flex flex-wrap align-items-center text-center">
                                    <div
                                        v-for="typeModifier in temBonuses1"
                                        :key="typeModifier.type"
                                        v-b-tooltip="typeModifier.type"
                                        class="type-multiplier-column d-flex flex-column"
                                    >
                                        <img class="type-icon align-self-center" :src="'/images/types/' + typeModifier.type + '.png'" />
                                        <div v-if="settingsStore.showTypeLabels" class="type-label">{{ typeModifier.type }}</div>
                                        <div class="multiplier-wrap align-self-center">
                                            <div v-if="typeModifier.modifier === 0.5" class="value-box value-bad multiplier-value">&#189;</div>
                                            <div v-else-if="typeModifier.modifier === 0.25" class="value-box value-very-bad multiplier-value">
                                                &#188;
                                            </div>
                                            <div v-else class="value-box" :class="typeModifier.modifier === 4 ? 'value-very-good' : 'value-good'">
                                                <span class="multiplier-symbol">x</span>
                                                <span class="multiplier-value">{{ typeModifier.modifier }}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div v-if="temSecondaryType" class="d-flex align-items-center mt-2">
                                <div class="icon-vs-wrap d-flex align-items-center">
                                    <img class="type-icon icon-vs" :src="'/images/types/' + temSecondaryType + '.png'" />
                                    <span class="fs-5">&#187;</span>
                                </div>
                                <div class="types-wrap d-flex flex-wrap align-items-center text-center">
                                    <div
                                        v-for="typeModifier in temBonuses2"
                                        :key="typeModifier.type"
                                        v-b-tooltip="typeModifier.type"
                                        class="type-multiplier-column d-flex flex-column"
                                    >
                                        <img class="type-icon align-self-center" :src="'/images/types/' + typeModifier.type + '.png'" />
                                        <div v-if="settingsStore.showTypeLabels" class="type-label">{{ typeModifier.type }}</div>
                                        <div class="multiplier-wrap align-self-center">
                                            <div v-if="typeModifier.modifier === 0.5" class="value-box value-bad multiplier-value">&#189;</div>
                                            <div v-else-if="typeModifier.modifier === 0.25" class="value-box value-very-bad multiplier-value">
                                                &#188;
                                            </div>
                                            <div v-else class="value-box" :class="typeModifier.modifier === 4 ? 'value-very-good' : 'value-good'">
                                                <span class="multiplier-symbol">x</span>
                                                <span class="multiplier-value">{{ typeModifier.modifier }}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>

                <tr>
                    <td colspan="2" class="col-spacer"></td>
                </tr>

                <tr>
                    <td>Catch Mod</td>
                    <td>
                        <span>{{ temData.catchRate }}</span>
                        <a
                            v-b-tooltip="'View capture formula'"
                            class="ms-1 fs-small fw-bold"
                            href="https://temtem.wiki.gg/wiki/Taming#Capture_formula"
                            target="_blank"
                            >📖</a
                        >
                        <span
                            v-if="temData.evolution?.evolutionTree?.length === 3 && temData.evolution.evolutionTree[2].name === temData.name"
                            v-b-tooltip="'Stage 3 evolution Tems cannot be caught normally'"
                            class="text-warning fs-small"
                        >
                            ⚠
                        </span>
                    </td>
                </tr>
                <tr>
                    <td>TV Yield</td>
                    <td>
                        <div class="d-flex align-items-center">
                            <div v-for="(tvYield, key, index) in filteredTvYields" :key="key" class="lh-sm pe-2">
                                <div class="stat-box d-flex align-items-center">
                                    <img class="stat-icon" :class="index !== 0 ? 'ps-1' : ''" :src="'/images/stats/' + key + '.png'" />
                                    <span class="text-uppercase fs-small">{{ key }}</span>
                                    <span class="ps-1 fs-small">+{{ tvYield }}</span>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>Egg Hatch</td>
                    <td>
                        {{ temData.hatchMins }}
                        <span class="fs-tiny">mins</span>
                    </td>
                </tr>

                <tr>
                    <td colspan="2" class="col-spacer"></td>
                </tr>

                <tr>
                    <td colspan="2" class="col-spacer"></td>
                </tr>

                <tr>
                    <td>Location(s)</td>
                    <td>
                        <div class="location-wrap">
                            <div v-if="temData.locations.length > 0">
                                <div v-for="(location, index) in temData.locations" :key="index" class="lh-xs pb-1">
                                    <a :href="'https://temtem.wiki.gg/index.php?search=' + location.island" target="_blank">
                                        {{ location.island }}
                                    </a>
                                    <span class="px-1 fs-tiny">&gt;</span>
                                    <a :href="'https://temtem.wiki.gg/index.php?search=' + location.location" target="_blank">
                                        <span class="fs-small">{{ location.location }}</span>
                                    </a>
                                    <span class="fs-tiny ps-1">{{ location.frequency }}</span>
                                </div>
                            </div>
                            <div v-else-if="temData.evolution?.evolutionTree?.length > 1 && temData.evolution.evolutionTree[0].name !== temData.name">
                                <span class="fs-tiny">Evolution</span>
                            </div>
                            <div v-else>
                                🥚
                                <span class="fs-tiny">Breeding</span>
                            </div>
                        </div>
                    </td>
                </tr>

                <tr>
                    <td colspan="2" class="col-spacer"></td>
                </tr>

                <tr>
                    <td>Evolution</td>
                    <td>
                        <div v-if="temData.evolution.evolves" class="fit-table-cell-width">
                            <span v-for="(evolutionTem, index) in temData.evolution.evolutionTree" :key="index" class="pe-1">
                                <span v-if="index !== 0" class="fs-tiny pe-1">&gt;</span>
                                <a :href="'https://temtem.wiki.gg/index.php?search=' + evolutionTem.name" target="_blank">
                                    <span :class="temData.name === evolutionTem.name ? 'fw-bold' : 'fs-small'">{{ evolutionTem.name }}</span>
                                </a>
                            </span>
                        </div>
                        <div v-else>n/a</div>
                    </td>
                </tr>
            </table>
        </template>
        <template v-else>
            <div>n/a</div>
        </template>
    </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import Checkbox from 'primevue/checkbox';
import Dropdown from 'primevue/dropdown';

import { useSettingsStore } from '@/store/settings';
import { useTemStore } from '@/store/tem';
import { getTypeBonuses, getTemTypeResistanceModifiers } from '@/utility/typeBonus';
import { TemType } from '@/constants/temTypes';
import { DynamicTypeTems } from '@/constants/temDetails';

const props = defineProps({
    tem: {
        type: Object,
        required: true,
    },
    label: {
        type: String,
        required: false,
        default: '',
    },
});

const settingsStore = useSettingsStore();
const temStore = useTemStore();

const selectedDynamicType = ref();
const temTypeOptions = ref(Object.keys(TemType).map(type => ({ label: TemType[type], value: type })));

const isIridescenceActive = ref(false);
const isPigmentInverterActive = ref(false);

const temRecord = computed(() => temStore.getApiRecord(props.tem.name));
const temData = computed(() => temRecord.value || {});
const temName = computed(() => temData.value.name);
const temTraitsData = computed(() => temStore.traitData);
const temSecondaryType = computed(() =>
    isTemDynamicType.value && selectedDynamicType.value ? selectedDynamicType.value?.label : temData.value.types?.[1],
);
const temImageUrl = computed(() => (settingsStore.showAnimatedTemGifs ? temData.value.wikiRenderAnimatedUrl : temData.value.wikiRenderStaticUrl));
const temLumaImageUrl = computed(() =>
    settingsStore.showAnimatedTemGifs ? temData.value.wikiRenderAnimatedLumaUrl : temData.value.wikiRenderStaticLumaUrl,
);
const isTemDynamicType = computed(() => DynamicTypeTems.has(temName.value));
const filteredTvYields = computed(() => {
    const tvYields = {};
    for (const [key, value] of Object.entries(temData.value.tvYields)) {
        if (value > 0) {
            tvYields[key] = value;
        }
    }
    return tvYields;
});
const temTypeResistanceModifiers = computed(() => {
    if (temData.value.types) {
        const type1 = temData.value.types[0];
        const type2 = temSecondaryType.value;
        return getTemTypeResistanceModifiers({ type1, type2, excludeDefaults: true, applyInverse: isIridescenceActive.value });
    }
    return {};
});
const temBonuses1 = computed(() => {
    if (temData.value.types) {
        const type1 = temData.value.types[0];
        return getTypeBonuses({ type: type1, excludeDefaults: true, applyInverse: isPigmentInverterActive.value });
    }
    return {};
});
const temBonuses2 = computed(() => {
    if (temData.value.types) {
        const type2 = temSecondaryType.value;
        return getTypeBonuses({ type: type2, excludeDefaults: true, applyInverse: isPigmentInverterActive.value });
    }
    return {};
});

watch(temName, (oldName, newName) => {
    if (oldName !== newName) {
        selectedDynamicType.value = null;
    }
});
</script>

<style scoped lang="scss">
.temCard {
    position: relative;
    align-self: stretch;
    width: 45%;
    flex-grow: 1;
    flex-shrink: 1;
    max-width: 500px;
    min-width: 330px;
    margin: 0.5rem;
    padding: 1rem 1rem 0 1rem;
    border: 1px solid #333;
    border-radius: 0.5rem;

    .card-label {
        position: absolute;
        top: 0;
        left: 0;
        padding: 0rem 0.4rem;
        background-color: #333;
        color: #fff;
        font-size: 0.8rem;
        border-radius: 0.5rem 0 0 0;
    }
    .tem-avatar {
        width: auto;
        height: 6.5rem;
        padding: 0 0.5rem;

        &.small {
            height: 2.8rem;
        }
    }

    .tem-number-hash {
        margin-right: 0.1rem;
        font-size: 0.8rem;
        color: #aaa;
        font-family: Rubik;
    }
    .tem-number {
        margin-right: 0.6rem;
        font-size: 1.1rem;
        color: #aaa;
        display: inline-flex;
        position: relative;
        font-family: Rubik;
    }

    .tem-name {
        //letter-spacing: 1px;
        font-size: 2rem;
        font-family: Rubik;
        font-weight: 700;
        text-shadow: 1px 0 2 #000, 0 1px 2 #000, -1px 0 2 #000, 0 -1px 2 #000;
        color: #ddd;
        &:hover {
            color: rgb(100, 108, 255);
        }
    }

    .table-details {
        tr {
            td {
                padding: 0.2rem 0.2rem;
            }
            td:not(.col-spacer):first-child {
                text-align: right;
                font-size: 0.8rem;
                width: 16%;
                white-space: nowrap;
                color: rgb(134, 140, 146);
                border: 2px solid #212529;
                border-radius: 0.4rem;
                background-color: rgba(255, 255, 255, 0.04);
            }
            td:last-child {
                text-align: left;
                font-size: 0.9rem;
            }
            td.col-spacer {
                padding: 0;
                height: 0.5rem;
            }
        }
    }

    .traits-wrap {
        a {
            font-weight: 400;
        }

        .trait-checkbox {
            margin-left: 0.5rem;
            margin-top: 3px;
        }

        :deep(.p-checkbox) {
            width: 0.8rem;
            height: 0.8rem;

            .p-checkbox-box {
                width: 0.8rem;
                height: 0.8rem;
            }
        }
    }

    .tem-types {
        padding: 0.4rem 0;
    }

    .type-icon {
        height: 1.3rem;
        width: auto;
        vertical-align: bottom;
        margin-right: 0.1rem;
    }
    .type-label {
        margin-top: -0.1rem;
        font-size: 0.55rem;
        font-weight: 600;
        line-height: 1;
        height: 0.8rem;
        width: 0;
        min-width: 100%;
        color: rgba(255, 255, 255, 0.6);
    }

    .icon-vs-wrap {
        width: 4rem;
        justify-content: center;
        .icon-vs {
            height: 2.2rem;
        }
    }

    .stat-icon {
        height: 1.1rem;
        width: auto;
        vertical-align: middle;
        margin-right: 0.3rem;
        filter: invert(100%) brightness(110%);
    }

    .types-wrap {
        .type-multiplier-column {
            margin-right: 0.1rem;
        }
        .type-icon {
            height: 1.8rem;
        }
        .multiplier-wrap {
            margin-top: 0.1rem;
            font-family: Rubik;
            font-weight: 400;
        }
        .value-box {
            width: 1.7rem;
            height: 1.3rem;
            border-radius: 4px;
            font-size: 0.7rem;
            line-height: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
        }
        .multiplier-value {
            font-weight: 500;
        }
        .value-good {
            background-color: #51772a;
        }
        .value-very-good {
            background-color: #699b38;
        }
        .value-bad {
            font-size: 1rem;
            font-weight: 500;
            background-color: #ac4a55;
        }
        .value-very-bad {
            font-size: 1rem;
            font-weight: 500;
            background-color: #692930;
        }
        .multiplier-symbol {
            margin-right: 0.05rem;
        }
    }

    .location-wrap {
        a {
            font-weight: 400;
        }
    }
}

.modal-content {
    .temCard {
        width: 100%;
        margin: 0;
        border: none;
    }
}
</style>

<style lang="scss">
.p-inputtext,
.p-dropdown-panel .p-dropdown-items .p-dropdown-item {
    color: rgb(173, 181, 189);
}

.tem-type-select {
    min-height: 32px;
    border: 1px solid rgba(63, 75, 91, 0.25);
    background: transparent;

    &:hover {
        border: 1px solid rgba(63, 75, 91, 1);
    }

    .p-inputtext {
        padding: 0.24rem 0.5rem;
        font-size: 0.8rem;
        display: flex;
        align-items: center;
    }
    .p-icon {
        width: 0.75rem;
        height: 0.75rem;
    }
    .p-dropdown-clear-icon {
        margin-top: -0.3rem;
    }
}

.tem-type-select-options {
    color: rgb(173, 181, 189);
    font-size: 0.8rem;

    .p-dropdown-items .p-dropdown-item {
        padding: 0.5rem 0.5rem;
    }

    .type-icon {
        height: 1.3rem;
        width: auto;
        vertical-align: bottom;
        margin-right: 0.1rem;
    }
}
</style>
