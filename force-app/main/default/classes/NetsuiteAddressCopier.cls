/*
 * this is intended to be temporary (fingers crossed)
 * it is intended to fill the NetSuite Address Fields for the report entitled
 * "Recently Updated Accounts LAST STATUS UP"
 * 
 */

global class NetsuiteAddressCopier  implements Database.Batchable<sObject>{
    
    global String Query;
    
    global NetsuiteAddressCopier() {
        Query = 'SELECT Id, AddressBuilder_Shipping__c, Name, LegalCompanyName__c, NetsuiteAddr1__c, NetsuiteAddr2__c, '
            + 'SF_SoldTo_Contact__r.Name, SF_SoldTo_Contact__r.FirstName, SF_BillTo_Contact__r.Name, SF_BillTo_Contact__r.FirstName '
            + 'FROM Account ';
        if (!test.isRunningTest()) Query += 'WHERE Id IN (SELECT AccountId FROM AccountHistory WHERE CreatedDate >= YESTERDAY AND Field IN (\'Name\',\'LegalCompanyName__c\',\'AddressBuilder_Shipping__c\'))';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject a : scope){
            system.debug(json.serialize(a));
            Contact c = (Contact)a.getSObject('SF_SoldTo_Contact__r');
            if ((String)a.get('AddressBuilder_Shipping__c') == null) {
                a.put('NetsuiteAddr1__c', (String)a.get('LegalCompanyName__c'));
                a.put('NetsuiteAddr2__c', c.FirstName == '[not provided]' ? null : c.Name);
            } else {
                String abs = ((String)a.get('AddressBuilder_Shipping__c')).replace('\\"','"');
                List<String> Blocks = (List<String>)JSON.deserialize(
                    abs,
                    List<String>.class
                );
                try{a.put('NetsuiteAddr1__c', getAddressLine(a, Blocks[0].split('\\.')));}catch(exception e){ a.put('NetsuiteAddr1__c', null); }
                try{a.put('NetsuiteAddr2__c', getAddressLine(a, Blocks[1].split('\\.')));}catch(exception e){ a.put('NetsuiteAddr2__c', null); }
            }
            if ((String)a.get('NetsuiteAddr1__c') == 'empty' || (String)a.get('NetsuiteAddr1__c') == 'null') a.put('NetsuiteAddr1__c', null);
            if ((String)a.get('NetsuiteAddr2__c') == 'empty' || (String)a.get('NetsuiteAddr2__c') == 'null') a.put('NetsuiteAddr2__c', null);
        }
        update scope;
    }
    
    global String getAddressLine(sObject a, List<String> Fields) {
        try {
            if (Fields.size() == 1) {
                return (String)a.get(Fields[0]);
            }
            return (String)a.getSObject(Fields[0]).get(Fields[1]); 
        } catch(exception e){ return Fields[0]; }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}