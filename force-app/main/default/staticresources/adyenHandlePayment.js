let checkout;

function renderAdyenComponent(paymentMethodsResponse) {
    //TODOBAS This will be configurable in later phase. Also client key instead of originKey
    const configuration = {
        locale: "en_US",
        environment: "test",
        clientKey: "test_V34KOGIDVJHLTOSMCTHATSWM5AFOQB6M",
        paymentMethodsResponse: paymentMethodsResponse,
        onChange: handleOnChange,
    };
    checkout = new AdyenCheckout(configuration);

    paymentMethodsResponse.paymentMethods.forEach((pm) =>
        renderPaymentMethod(pm)
    );

    selectFirstPaymentMethod();
}

function handleOnChange(state){
    //handleOnChange
}

function renderPaymentMethod(paymentMethod){
    paymentMethod.type = paymentMethod.type == "scheme" ? "card" : paymentMethod.type;
    const paymentMethodsUI = document.querySelector('#paymentMethodsList');
    const container = document.createElement('div');
    const li = document.createElement('li');
    configureListItem(paymentMethod, li);
    configureContainer(paymentMethod.type, container);
    li.append(container);
    paymentMethodsUI.append(li);
    handleInput(paymentMethod.type);

    try {
        const node = checkout.create(paymentMethod.type).mount(container);
    } catch (e) {
        /* No component for payment method */
    }
}

function configureListItem(paymentMethod, li){
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

function selectFirstPaymentMethod(){
    const firstPaymentMethod = document.querySelector(
    'input[type=radio][name=brandCode]',
    );
    firstPaymentMethod.checked = true;
    displaySelectedMethod(firstPaymentMethod.value);
}

function displaySelectedMethod(type){
    $('.additionalFields').hide();
    document
        .querySelector(`#component_${type}`)
        .setAttribute('style', 'display:block');
}

function convertToJsonObject(jsonString){
    jsonString = jsonString.replace(/&quot;/g, '\"');
    return JSON.parse(jsonString);
}