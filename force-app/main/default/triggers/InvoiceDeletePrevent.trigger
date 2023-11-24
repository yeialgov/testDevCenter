trigger InvoiceDeletePrevent on Invoice__c (before delete) {
    for (Invoice__c inv : Trigger.old) {
        if(inv.HasBeenEmailed__c) inv.addError('Invoices cannot be deleted.');
    }
}