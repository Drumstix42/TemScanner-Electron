import * as _ from 'lodash-es';

export const parseTemName = (temName = '') => {
    // remove periods, commas, dashes, and remove any characters after a trailing space
    const cleanName = _.deburr(temName);
    return cleanName
        .replace(/[\.,-]/g, '')
        .replace(/ +\S*$/, '')
        .toLowerCase();
};

export const findPartialNameMatch = ({ name, dictionary, accuracy = 0.7 }) => {
    if (!name || !dictionary) {
        return null;
    }

    const names = Object.keys(dictionary);

    const match = names.find(record => {
        const nameArray = name.split('');
        const recordArray = record.split('');
        const nameLength = nameArray.length;
        const recordLength = recordArray.length;
        let nameIndex = 0;
        let recordIndex = 0;
        let matches = 0;
        while (nameIndex < nameLength && recordIndex < recordLength) {
            if (nameArray[nameIndex] === recordArray[recordIndex]) {
                matches += 1;
                nameIndex += 1;
                recordIndex += 1;
            } else {
                recordIndex += 1;
            }
        }
        const matchAccuracy = matches / nameLength;
        return matchAccuracy >= accuracy;
    });

    if (match) {
        console.info('partial match found - ', { value: match });
    }

    return dictionary[match];
};
