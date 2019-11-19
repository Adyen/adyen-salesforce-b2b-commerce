/**
 * @param cardNumber [String] - unformatted number
 * @returns Boolean
 */
function luhnCheck(cardNumber){

    if ( isNaN( parseInt( cardNumber, 10 ) ) ) {
        return false;
    }

    const no_digit = cardNumber.length;
    const oddeven = no_digit & 1;
    let sum = 0;

    for ( let count = 0; count < no_digit; count++ ) {
        let digit = parseInt( cardNumber.charAt( count ), 10 );
        if ( ! ( ( count & 1 ) ^ oddeven ) ) {
            digit *= 2;
            if ( digit > 9 ){
                digit -= 9;
            }
        }
        sum += digit;
    }

    return ( sum % 10 === 0 );
}

function loadingToggle(){
    $('#overlayCustom').toggle();
}