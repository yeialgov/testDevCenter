global class CCPD_Calculator implements Database.Batchable<sObject>{
    
    global final String Query;
    
    global CCPD_Calculator() {
        Query = 'SELECT Id, CCD_IO__c, Closed_Contract_Paid_Date__c, '
            + '(SELECT Id FROM Invoices1__r WHERE Status__c = \'Posted\' ORDER BY Name LIMIT 4),('
            + '   SELECT Id, AdjustmentDate__c FROM Credit_Balance_Adjustments__r '
            + '   WHERE SourceTransactionType__c = \'Payment\' AND Type__c = \'Increase\' '
            + '   ORDER BY Name DESC LIMIT 1'
            + ') '
            + 'FROM Account '
            + 'WHERE Id IN (SELECT Account__c FROM Subscription__c) '
            + ' AND (Closed_Contract_Paid_Date__c = null OR Closed_Contract_Paid_Date__c >= LAST_n_DAYS:15) '
            + ' AND Id IN (SELECT CustomerAccount__c FROM Invoice__c WHERE Status__c = \'Posted\' AND (InvoiceDate__c >= 2018-01-01 OR InstalmentCharges__c > 0)) '
            + ' AND Set_CCPD_manually__c = false';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Id> InvoiceIds = new List<Id>();
        for(sObject s : scope){
            for(sObject ss : (List<sObject>)s.getSObjects('Invoices1__r')){
                InvoiceIds.add((Id)ss.get('Id'));
            }
        }
        List<sObject> InvoiceList = [
            SELECT Id, CustomerAccount__c, Balance__c, CreditBalanceAdjustmentAmount__c, InstalmentCharges__c, Amount__c, (
                SELECT Id, PaidDate__c
                FROM Invoice_Payments__r 
                WHERE IsQualifyingPayment_formula__c = TRUE
                ORDER BY PaidDate__c DESC 
                LIMIT 1
            )
            FROM Invoice__c 
            WHERE Id IN :InvoiceIds
            ORDER BY Name
        ];
        Map<Id,List<sObject>> InvoiceMap = new Map<Id,List<sObject>>();
        for (sObject inv : InvoiceList){
            if(InvoiceMap.get((Id)inv.get('CustomerAccount__c'))==null) InvoiceMap.put((Id)inv.get('CustomerAccount__c'), new List<sObject>());
            InvoiceMap.get((Id)inv.get('CustomerAccount__c')).add(inv);
        }
        for(sObject s : scope){
            sObject RelevantInvoice = null;
            for (sObject ss : InvoiceMap.get((Id)s.get('Id'))){
                if (RelevantInvoice == null){
                    if(
                        (Decimal)ss.get('Balance__c') > 0 || (List<sObject>)ss.getSObjects('Invoice_Payments__r')!=null || (Decimal)ss.get('CreditBalanceAdjustmentAmount__c') < 0
                    ) RelevantInvoice = ss;
                }
            }
            if (RelevantInvoice == null) {
                s.put('Closed_Contract_Paid_Date__c', null);
            }else if (
                ((Decimal)RelevantInvoice.get('InstalmentCharges__c') > 0
                &&
                (Decimal)RelevantInvoice.get('Balance__c') > (Decimal)RelevantInvoice.get('Amount__c') * (18.0/25.0)) // 18/25 replaces 2/3 per Peter Helf CDS-1485
                ||
                ((Decimal)RelevantInvoice.get('InstalmentCharges__c') < 1
                &&
                (Decimal)RelevantInvoice.get('Balance__c') != 0)
                ||
                ((List<sObject>)RelevantInvoice.getSObjects('Invoice_Payments__r')==null 
                && 
                (List<sObject>)s.getSObjects('Credit_Balance_Adjustments__r')==null)
            ){
                s.put('Closed_Contract_Paid_Date__c', null);
            } else {
                Date CreBalDate; try{CreBalDate = (Date)(s.getSObjects('Credit_Balance_Adjustments__r')[0].get('AdjustmentDate__c'));}catch(exception e){}
                DateTime InvPmtDT; try{InvPmtDT = (DateTime)(RelevantInvoice.getSObjects('Invoice_Payments__r')[0].get('PaidDate__c'));}catch(exception e){}
                Date InvPmtDate = ConvertDateTime(InvPmtDT, (Date)s.get('CCD_IO__c'));

                if (CreBalDate != null && s.get('Closed_Contract_Paid_Date__c') == null) { s.put('Closed_Contract_Paid_Date__c', CreBalDate);
                } else if (CreBalDate == null){ s.put('Closed_Contract_Paid_Date__c', InvPmtDate);
                }
            }
        }
        update scope;
    }
    
    global Date ConvertDateTime(DateTime dt, Date d2){
        if (dt==null) return null;
        Date d1 = Date.newInstance(dt.year(), dt.month(), dt.day());
        if (d2 == null) return d1;
        if (d1 < d2) {
            return d1;
        } else {
            return d2;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}