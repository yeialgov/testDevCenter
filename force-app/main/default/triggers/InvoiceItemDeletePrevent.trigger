trigger InvoiceItemDeletePrevent on InvoiceLineItem__c (before delete) {
    for (InvoiceLineItem__c ii : Trigger.old) {}//ii.addError('Invoice Line Items cannot be deleted.');
}