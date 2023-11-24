trigger OBInvItemInsert on OBInvoiceItem__c (before insert) {

    Map<String, ObInvoiceItem__c> InvoiceNameMap = new Map<String, ObInvoiceItem__c>();
    Map<String, ObInvoice__c> InvoiceMap = new Map<String, ObInvoice__c>();
    Map<String, Integer> NewInvoiceMap = new Map<String, Integer>();
    Map<String, Id> ProdCodeMap = new Map<String, Id>();
    Set<String> ProductCodes = new Set<String>();
    List<ObInvoice__c> NewInvoices = new List<ObInvoice__c>();
    Map<String, OBInvoiceMapping__c> FieldMapping = OBInvoiceMapping__c.getAll();
    for (ObInvoiceItem__c Item : trigger.new) {
        InvoiceNameMap.put(Item.InvoiceName__c, Item);
        ProductCodes.add(Item.ProductCode__c);
    }
    for (Product2 p : [SELECT Id, ExternalId FROM Product2 WHERE IsActive = TRUE AND ExternalId IN :ProductCodes ORDER BY CreatedDate]) {
        ProdCodeMap.put(p.ExternalId, p.Id);
    }
    for (ObInvoice__c Invoice : [SELECT Id, ExternalId__c FROM ObInvoice__c WHERE ExternalId__c IN :InvoiceNameMap.keySet()]) {
        InvoiceMap.put(Invoice.ExternalId__c, Invoice);
    }
    Set<String> NewInvoiceNames = InvoiceNameMap.keySet().clone();
    NewInvoiceNames.removeAll(InvoiceMap.keySet());
    Integer x = 0;
    for (String InvoiceName : NewInvoiceNames) {
        OBInvoice__c Invoice = new OBInvoice__c(ExternalId__c = InvoiceName, Name = InvoiceName);
        for (String InvFld : FieldMapping.keySet()) {
            Invoice.put(InvFld, InvoiceNameMap.get(InvoiceName).get(FieldMapping.get(InvFld).OBInvoiceItem_Field__c));
        }
        NewInvoices.add(Invoice);
        NewInvoiceMap.put(InvoiceName, x);
        x++;
    }
    insert NewInvoices;
    for (ObInvoiceItem__c Item : trigger.new) {
        if (Item.ProductCode__c != null && Item.Product__c == null) Item.Product__c = ProdCodeMap.get(Item.ProductCode__c);
        if (InvoiceMap.get(Item.InvoiceName__c) == null) {
        	Item.Invoice__c = NewInvoices[NewInvoiceMap.get(Item.InvoiceName__c)].Id;
        } else {
            Item.Invoice__c = InvoiceMap.get(Item.InvoiceName__c).Id;
        }
    }
}