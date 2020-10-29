trigger TransactionPaymentTrigger on ccrz__E_TransactionPayment__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        //TransactionPaymentHandler.capturePayments(Trigger.New, Trigger.oldMap);
    }
}