const checkout = {};
const componentsObj = {};

renderAdyenComponent = paymentMethodsResponse => {
    //TODOBAS This will be configurable in later phase. Also client key instead of originKey
    const configuration = {
        locale: "en_US",
        environment: "test",
        clientKey: "test_V34KOGIDVJHLTOSMCTHATSWM5AFOQB6M",
        paymentMethodsResponse: paymentMethodsResponse,
        paymentMethodsConfiguration: getPaymentMethodsConfig(),
        onChange: handleOnChange,
        onAdditionalDetails: handleOnAdditionalDetails,
    };
    checkout.adyenCheckout = new AdyenCheckout(configuration);

    paymentMethodsResponse.paymentMethods.forEach((pm) =>
        renderPaymentMethod(pm)
    );

    selectFirstPaymentMethod();
}

getPaymentMethodsConfig = () => {
    return {
        card: {
            brands: ['mc','visa','amex'],
            enableStoreDetails: !isGuest,
            hasHolderName: true,
            holderNameRequired: true,
            onBrand: handleOnBrand,
        }
    }
}
handleOnBrand = brand => {
    console.log(brand);
}

handleOnChange = state => {
    const type = state.data.paymentMethod.type == "scheme" ? "card" : state.data.paymentMethod.type;
    if (!componentsObj[type]) {
        componentsObj[type] = {};
    }
    componentsObj[type].isValid = state.isValid;
    componentsObj[type].stateData = state.data;
}

handleOnAdditionalDetails = state => {
    document.querySelector('#adyenStateData').value = JSON.stringify(
        state.data,
    );
    console.log(state);
    var paymentsDetailsResult = sforce.apex.execute("AdyenWebService", "adyenPaymentsDetails", state);
    console.log(paymentsDetailsResult);
    // Visualforce.remoting.Manager.invokeAction(
    //     '{!$RemoteAction.PmtAdyenPayController.adyenPaymentsDetails}',
    //     CCRZ.pagevars.remoteContext,
    //     document.getElementById("adyenStateData").value,
    //     //create general function
    //     function(result, event){
    //         if (!result.data.isFinal && result.data.action) {
    //              //handle payment action
    //             handleAction(result.data.action);
    //         } else if(result.data.ordId) {
    //             var orderSuccessUrl = new URL(CCRZ.pagevars.currSiteURL + 'ccrz__OrderConfirmation');
    //             orderSuccessUrl.searchParams.append('o', result.data.ordId);
    //             window.location.href = orderSuccessUrl;
    //         } else {
    //             self.model.errors = result.messages;
    //             return false;
    //         }
    //     },
    //     { escape: true }
    // );
}

renderPaymentMethod = paymentMethod => {
    paymentMethod.type = paymentMethod.type == "scheme" ? "card" : paymentMethod.type;
    const paymentMethodsUI = document.querySelector('#paymentMethodsList');
    const container = document.createElement('div');
    const li = document.createElement('li');
    configureListItem(paymentMethod, li);
    configureContainer(paymentMethod.type, container);
    li.append(container);
    paymentMethodsUI.append(li);
    handleInput(paymentMethod.type);

    const node = createNode(paymentMethod.type);
    if (node) {
        node.mount(container);
    }
}

createNode = paymentMethod => {
    if (!componentsObj[paymentMethod]) {
        componentsObj[paymentMethod] = {};
    }
    try {
        const node = checkout.adyenCheckout.create(paymentMethod)
        componentsObj[paymentMethod].node = node;
        return node;
    } catch (e) {
        /* No component for payment method */
        componentsObj[paymentMethod].isValid = true;
        return;
    }
}

configureListItem = (paymentMethod, li) => {
    const liContents = `
                         <input name="brandCode" type="radio" value="${paymentMethod.type}" id="rb_${paymentMethod.type}">
                         <img class="paymentMethod_img" src="https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/medium/${paymentMethod.type}.png">
                         <label id="lb_${paymentMethod.type}" for="rb_${paymentMethod.type}">${paymentMethod.name}</label>
                       `;
    li.innerHTML = liContents;
    li.classList.add('paymentMethod');
}

configureContainer = (paymentMethodType, container) => {
    container.classList.add('additionalFields');
    container.setAttribute('id', `component_${paymentMethodType}`);
    container.setAttribute('style', 'display:none');
}

handleInput = paymentMethodType => {
    const input = document.querySelector(`#rb_${paymentMethodType}`);
    input.onchange = (event) => {
        displaySelectedMethod(event.target.value);
    };
}

selectFirstPaymentMethod = () => {
    const firstPaymentMethod = document.querySelector(
        'input[type=radio][name=brandCode]',
    );
    firstPaymentMethod.checked = true;
    displaySelectedMethod(firstPaymentMethod.value);
}

displaySelectedMethod = type => {
    checkout.selectedMethod = type;
    $('.additionalFields').hide();
    document
        .querySelector(`#component_${type}`)
        .setAttribute('style', 'display:block');
}

validateComponent = () => {
    const type = checkout.selectedMethod;
    if (componentsObj[type].isValid) {
        assignStateData();
        return true;
    }
    componentsObj[type].node.showValidation();
    return;
}

assignStateData = () => {
    const type = checkout.selectedMethod;
    const hasStateData = componentsObj[type] && componentsObj[type].stateData;
    const stateData = hasStateData ? componentsObj[type].stateData : {paymentMethod: {type: selectedMethod}}
    stateData.origin = window.location.origin;
    document.querySelector('#adyenStateData').value = JSON.stringify(
        stateData,
    );
}

convertToJsonObject = jsonString => {
    jsonString = jsonString.replace(/&quot;/g, '\"');
    return JSON.parse(jsonString);
}

decodeJsonObject = jsonObject => {
    var elem = document.createElement('textarea');
    elem.innerHTML = JSON.stringify(jsonObject);;
    return JSON.parse(elem.value);
}

handleAction = action => {
    const decodedAction = decodeJsonObject(action);
    checkout.adyenCheckout.createFromAction(decodedAction).mount('#action-container');
}
