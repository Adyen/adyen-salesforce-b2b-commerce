function renderAdyenComponent(paymentMethodsResponse) {
    //TODOBAS This will be configurable in later phase. Also client key instead of originKey
    const configuration = {
        locale: "en_US",
        environment: "test",
        originKey: "pub.v2.8115716704476750.aHR0cHM6Ly9iMmItc2NvcGluZy0wOTIwLWRldmVsb3Blci1lZGl0aW9uLm5hMTM5LmZvcmNlLmNvbQ.Ilcqb9JijpuM1Q0qCZy2AeAA_89bns5qIdoQSsYgaYM",
        paymentMethodsResponse: paymentMethodsResponse,
        onChange: handleOnChange,
    };
    const checkout = new AdyenCheckout(configuration);
    //const card = checkout.create('card').mount('#component-container');

    paymentMethodsResponse.paymentMethods.forEach((pm) =>
            renderPaymentMethod(pm)
    );
}

function renderPaymentMethod(paymentMethod){
    console.log(paymentMethod);
    const paymentMethodsUI = document.querySelector('#paymentMethodsList');
    const container = document.createElement('div');
    const li = document.createElement('li');
    const liContents = `
                            <input name="brandCode" type="radio" value="${paymentMethod.type}" id="rb_${paymentMethod.type}">
                            <label id="lb_${paymentMethod.type}" for="rb_${paymentMethod.type}">${paymentMethod.name}</label>
                          `;

    li.innerHTML = liContents;
    li.classList.add('paymentMethod');

    try {
        const node = checkout.create(paymentMethod);
        node.mount(container);
    } catch (e) {
        /* No component for payment method */
    }

    li.append(container);
    paymentMethodsUI.append(li);
}

function handleOnChange(state){
    //handleOnChange
}