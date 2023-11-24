trigger InterwegaInsert on Interwega_Import__c (after insert) {
    
    Set<String> CustIdSet = new Set<String>();
    Map<String, Interwega_Import__c> IIMap = new Map<String, Interwega_Import__c>();
    List<Interwega_Import__c> delIIs = new List<Interwega_Import__c>();
    
    for (Interwega_Import__c ii : trigger.new) {
        CustIdSet.add(ii.CustomerId__c);
        IIMap.put(ii.CustomerId__c, ii);
        delIIs.add(new Interwega_Import__c(Id=ii.Id));
    }
    
    List<Account> Accts = [
        SELECT Id, CustomerId__c, Interwega_Debt_Collection_Id__c, Interwega_Business_Area__c, Interwega_Open_Balance_wo_fees__c, Interwega_Open_Balance__c, Interwega_Reference_Date__c, Interwega_Status__c 
        FROM Account
        WHERE CustomerId__c IN :CustIdSet
    ];
    
    for (Account a : Accts) {
        a.Interwega_Business_Area__c = IIMap.get(a.CustomerID__c).Interwega_Business_Area__c;
        a.Interwega_Open_Balance_wo_fees__c = IIMap.get(a.CustomerID__c).Interwega_Open_Balance_wo_fees__c;
        a.Interwega_Open_Balance__c = IIMap.get(a.CustomerID__c).Interwega_Open_Balance__c;
        a.Interwega_Reference_Date__c = IIMap.get(a.CustomerID__c).Interwega_Reference_Date__c;
        a.Interwega_Status__c = IIMap.get(a.CustomerID__c).Interwega_Status__c;
        a.Interwega_Debt_Collection_Id__c = IIMap.get(a.CustomerID__c).Interwega_Debt_Collection_Id__c;
    }
    
    update Accts;
    delete delIIs;
    
}