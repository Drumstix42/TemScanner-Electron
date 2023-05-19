function gcd(a, b) {
    return b ? gcd(b, a % b) : a;
}

export const decimalToFractionString = function (value) {
    if (value == parseInt(value)) {
        return parseInt(value);
    }
    let top = value.toString().includes('.') ? value.toString().replace(/\d+[.]/, '') : 0;
    const bottom = Math.pow(10, top.toString().replace('-', '').length);
    if (value >= 1) {
        top = +top + Math.floor(value) * bottom;
    } else if (value <= -1) {
        top = +top + Math.ceil(value) * bottom;
    }

    const x = Math.abs(gcd(top, bottom));
    return `${top / x}/${bottom / x}`;
};
