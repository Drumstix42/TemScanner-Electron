import { defineStore } from 'pinia';
import { findPartialNameMatch, parseTemName } from '@/utility/parseTemData';
import { incorrectTemOcrDictionary } from '@/constants/ocr';

export const useTemStore = defineStore('tem', {
    state: () => {
        return {
            apiData: {},
            traitData: {},
            tem1: {},
            tem2: {},
            jsonDateTime: null,
            hasAttemptedJsonFileLoad: false,
            isJsonFileAvailable: false,
            isJsonFileValid: false,
            temHistory: [],
            maxTemHistory: 10,
        };
    },

    getters: {
        getApiRecord: state => {
            return name => state.apiData[incorrectTemOcrDictionary[name]] || state.apiData[name];
        },
    },

    actions: {
        setTemApiData(data = []) {
            // map data array to object keyed by name
            this.apiData = data.reduce((acc, tem) => {
                // remove trailing parentheses and words inside parentheses
                tem.name = tem.name.replace(/ +.*(.*)/, '');
                // for each `tem.traits[]` replace < and > characters with spaces for Traits
                tem.cleanTraits = tem.traits.map(trait => trait.replace(/[<>]/g, ' ').trim());
                // lowercase key name
                const keyName = tem.name.toLowerCase();
                acc[keyName] = tem;
                return acc;
            }, {});
            console.log('apiData', this.apiData);
        },
        setTraitApiData(data = []) {
            // map data array to object keyed by name
            this.traitData = data.reduce((acc, trait) => {
                acc[trait.name] = trait;
                return acc;
            }, {});
            console.log('traitData', this.traitData);
        },
        setTemParseData({ jsonData } = {}) {
            if (!jsonData.datetime) {
                this.isJsonFileValid = false;
            } else {
                // TODO: this could be more strict, but it's not imperative
                this.isJsonFileValid = true;
            }
            // `jsonData.datetime` should be a larger number to indicate newer data
            if (this.jsonDateTime && this.jsonDateTime >= jsonData.datetime) {
                return;
            }

            const tem1 = { name: this.tem1.name };
            const tem2 = { name: this.tem2.name };

            if (!jsonData.tem1?.active && !jsonData.tem2?.active) {
                return;
            }

            if (jsonData.tem1?.active) {
                const parsedName = parseTemName(jsonData.tem1?.name);
                if (this.getApiRecord(parsedName)) {
                    tem1.name = parsedName;
                } else {
                    const matchedName = findPartialNameMatch({ name: parsedName, dictionary: this.apiData });
                    if (this.getApiRecord(matchedName)) {
                        tem1.name = matchedName;
                    }
                }
            } else {
                tem1.name = '';
            }

            if (jsonData.tem2?.active) {
                const parsedName = parseTemName(jsonData.tem2?.name);
                if (this.getApiRecord(parsedName)) {
                    tem2.name = parsedName;
                } else {
                    const matchedName = findPartialNameMatch({ name: parsedName, dictionary: this.apiData });
                    if (this.getApiRecord(matchedName)) {
                        tem2.name = matchedName;
                    }
                }
            } else {
                tem2.name = '';
            }

            this.tem1 = tem1;
            this.tem2 = tem2;
            this.jsonDateTime = jsonData.datetime;

            this.updateTemHistory();
        },

        updateTemHistory() {
            const tem1 = this.getApiRecord(this.tem1.name);
            const tem2 = this.getApiRecord(this.tem2.name);

            if (tem1) {
                const temKey = tem1.name.toLowerCase();
                const temHistory = [...this.temHistory];
                const newTemHistory = {
                    temKey,
                    datetime: this.jsonDateTime,
                };
                // remove duplicate entries
                const filteredTemHistory = temHistory.filter(historyRecord => historyRecord.temKey !== newTemHistory.temKey);
                // add new entry to the beginning of the array
                filteredTemHistory.unshift(newTemHistory);
                this.temHistory = filteredTemHistory.slice(0, this.maxTemHistory);
            }
            if (tem2) {
                const temKey = tem2.name.toLowerCase();
                const temHistory = [...this.temHistory];
                const newTemHistory = {
                    temKey,
                    datetime: this.jsonDateTime,
                };
                // remove duplicate entries
                const filteredTemHistory = temHistory.filter(historyRecord => historyRecord.temKey !== newTemHistory.temKey);
                // add new entry to the beginning of the array
                filteredTemHistory.unshift(newTemHistory);
                this.temHistory = filteredTemHistory.slice(0, this.maxTemHistory);
            }
            //console.log('temHistory', this.temHistory);
        },
    },
});
