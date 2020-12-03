const checkout = {};
const componentsObj = {};

function renderAdyenComponent(paymentMethodsResponse) {
    //TODOBAS This will be configurable in later phase. Also client key instead of originKey
    const configuration = {
        locale: "en_US",
        environment: "test",
        clientKey: "test_V34KOGIDVJHLTOSMCTHATSWM5AFOQB6M",
        paymentMethodsResponse: paymentMethodsResponse,
        paymentMethodsConfiguration: getPaymentMethodsConfig(),
        onChange: handleOnChange,
    };
    checkout.adyenCheckout = new AdyenCheckout(configuration);

    paymentMethodsResponse.paymentMethods.forEach((pm) =>
        renderPaymentMethod(pm)
    );

    selectFirstPaymentMethod();
}

function getPaymentMethodsConfig() {
    return {
        card: {
            enableStoreDetails: !isGuest,
            onChange(state) {
                const type = 'card';
                if (!componentsObj[type]) {
                    componentsObj[type] = {};
                }
                componentsObj[type].isValid = state.isValid;
                componentsObj[type].stateData = state.data;
            },
        }
    }
}

function handleOnChange(state) {
    const {type} = state.data.paymentMethod;
    if (!componentsObj[type]) {
        componentsObj[type] = {};
    }
    componentsObj[type].isValid = state.isValid;
    componentsObj[type].stateData = state.data;
}

function renderPaymentMethod(paymentMethod) {
    paymentMethod.type = paymentMethod.type == "scheme" ? "card" : paymentMethod.type;
    const paymentMethodsUI = document.querySelector('#paymentMethodsList');
    const container = document.createElement('div');
    const li = document.createElement('li');
    configureListItem(paymentMethod, li);
    configureContainer(paymentMethod.type, container);
    li.append(container);
    paymentMethodsUI.append(li);
    handleInput(paymentMethod.type);

    const node = createNode(paymentMethod.type)
    if (node) {
        node.mount(container);
    }
}

function createNode(paymentMethod) {
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

function configureListItem(paymentMethod, li) {
    const liContents = `
                         <input name="brandCode" type="radio" value="${paymentMethod.type}" id="rb_${paymentMethod.type}">
                         <img class="paymentMethod_img" src="https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/medium/${paymentMethod.type}.png">
                         <label id="lb_${paymentMethod.type}" for="rb_${paymentMethod.type}">${paymentMethod.name}</label>
                       `;
    li.innerHTML = liContents;
    li.classList.add('paymentMethod');
}

function configureContainer(paymentMethodType, container) {
    container.classList.add('additionalFields');
    container.setAttribute('id', `component_${paymentMethodType}`);
    container.setAttribute('style', 'display:none');
}

function handleInput(paymentMethodType) {
    const input = document.querySelector(`#rb_${paymentMethodType}`);
    input.onchange = (event) => {
        displaySelectedMethod(event.target.value);
    };
}

function selectFirstPaymentMethod() {
    const firstPaymentMethod = document.querySelector(
        'input[type=radio][name=brandCode]',
    );
    firstPaymentMethod.checked = true;
    displaySelectedMethod(firstPaymentMethod.value);
}

function displaySelectedMethod(type) {
    checkout.selectedMethod = type;
    $('.additionalFields').hide();
    document
        .querySelector(`#component_${type}`)
        .setAttribute('style', 'display:block');
}

function validateComponent() {
    const type = checkout.selectedMethod;
    if (componentsObj[type].isValid) {
        assignStateData();
        return true;
    }
    componentsObj[type].node.showValidation();
    return;
}

function assignStateData() {
    const type = checkout.selectedMethod;
    const hasStateData = componentsObj[type] && componentsObj[type].stateData;
    const stateData = hasStateData ? componentsObj[type].stateData : {paymentMethod: {type: selectedMethod}}
    document.querySelector('#adyenStateData').value = JSON.stringify(
        stateData,
    );
}

function convertToJsonObject(jsonString) {
    jsonString = jsonString.replace(/&quot;/g, '\"');
    return JSON.parse(jsonString);
}
