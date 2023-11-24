trigger InvoiceLineItemTrigger on InvoiceLineItem__c (after insert, after update) {
    Map<Id, Id> InvMap = new Map<Id, Id>();
    List<Invoice__c> Invoices = new List<Invoice__c>();
    for (InvoiceLineItem__c InvItem : Trigger.new) {
        if (InvItem.InvoiceNeedsCustomer__c) InvMap.put(InvItem.Invoice__c, InvItem.SubscriptionLineItem__c);
    }
    Map<Id, SubscriptionLineItem__c> SLIMap = new Map<Id, SubscriptionLineItem__c>([
        SELECT Id, Subscription__r.Account__c FROM SubscriptionLineItem__c WHERE Id IN :InvMap.values()
    ]);
    for (Id InvId : InvMap.keySet()) {
        try {
            Invoices.add(new Invoice__c(
                Id = InvId,
                CustomerAccount__c = SLIMap.get(InvMap.get(InvId)).Subscription__r.Account__c
            ));
        } catch(exception e){}
    }
    update Invoices;
}