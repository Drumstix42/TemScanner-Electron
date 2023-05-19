import { TypeModifiers } from '@/constants/temTypes';

const InverseModifierMap = Object.freeze({
    0.25: 4,
    0.5: 2,
    1: 1,
    2: 0.5,
    4: 0.25,
});

// calculate type strengths/weaknesses
export const getTemTypeResistanceModifiers = ({ type1, type2, excludeDefaults = false, applyInverse = false } = {}) => {
    const modifiers = [];

    for (const temType in TypeModifiers) {
        const vs1 = TypeModifiers[temType][type1] ?? 1;
        const vs2 = type1 !== type2 ? TypeModifiers[temType][type2] ?? 1 : 1;
        let modifier = vs1 * vs2;

        if (applyInverse) {
            modifier = InverseModifierMap[modifier] ?? modifier;
        }

        // `excludeDefaults` will exclude types with a modifier of 1
        if (!excludeDefaults || (excludeDefaults && modifier !== 1)) {
            modifiers.push({ type: temType, modifier });
        }
    }

    // sort by modifier
    return modifiers.sort((a, b) => b.modifier - a.modifier);
};

// calculate type bonuses (for attacking)
export const getTypeBonuses = ({ type, excludeDefaults = false, applyInverse = false } = {}) => {
    const typeModifier = type ? TypeModifiers[type] : {};
    const modifiers = [];

    for (const temType in typeModifier) {
        let modifier = typeModifier[temType] ?? 1;

        if (applyInverse) {
            modifier = InverseModifierMap[modifier] ?? modifier;
        }

        // `excludeDefaults` will exclude types with a modifier of 1
        if (!excludeDefaults || (excludeDefaults && modifier !== 1)) {
            modifiers.push({ type: temType, modifier });
        }
    }

    // sort by modifier
    return modifiers.sort((a, b) => b.modifier - a.modifier);
};
