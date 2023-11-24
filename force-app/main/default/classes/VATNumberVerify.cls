public class VATNumberVerify implements Database.Batchable<sObject>{
  
    public final String Query;
    public List<SObject> AcctUpdt;
	public map <Id,SObject> m1;
    
    public VATNumberVerify(){
        Query = 'SELECT Id, vatnumber_disp__c, vatnumber__c ' 
            + 'FROM Account ' 
            + 'WHERE'
            + ' vatnumber_disp__c != null'
            //+ ' createddate =< today' 
            + ' AND (NOT vatnumber_disp__c like \'%NULL%\')' 
            + ' AND Tax_Exempt_Status_formula__c=\'Yes\' ';
            //+ 'LIMIT 10';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Integer getVATVerify;
        AcctUpdt = new List <SObject>();
        for(sobject s : scope){
            AcctUpdt.add(s);
            //AcctUpdt.add((Account)s.getSobject('Account__r'));
            String VATNumber = (String)s.get('vatnumber__c');
            //getVATVerify = VIES.isValidVATID(VATNumber);
            //s.put('VATId_Status__c', getVATVerify);
        }
        system.debug(AcctUpdt.size());
        m1 = new Map<Id, SObject>(AcctUpdt);
        system.debug(m1.size()+' *map size');
        
        //update scope;
    }  

    public void finish(Database.BatchableContext BC){
    	
    }
}