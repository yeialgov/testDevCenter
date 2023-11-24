public class AccountStatus_Controller {
    
    @InvocableMethod(label='Update Account Status' description='Ensures Account Status is still correct')	
    public static void UpdateAccountStatus(List<Id> AccountIds) {
        String Query = 'SELECT Id, RecordType.Name, Account_Status__c, Number_of_Active_Subscriptions_2__c, NS_Customer_Internal_ID__c, Product_Test_Participation__c'
            + ' FROM Account WHERE Id IN :AccountIds';
        ExecuteAccountStatusUpdate(Database.query(Query));
    }
    
    public static void ExecuteAccountStatusUpdate(List<sObject> scope) {
        List<Account> UpdateAccounts = new List<Account>();
        Set<String> SubbedAccts = new Set<String>();
        Map<String, sObject> sObjectMap = new Map<String, sObject>();
        for(sObject s : scope){
            if ((String)s.getSObject('RecordType').get('Name') == 'Customer') {
                sObjectMap.put((String)s.get('Id'), s);
            } else if ((String)s.get('Account_Status__c') != 'Partner') { UpdateAccounts.add(new Account(Id = (String)s.get('Id'),Account_Status__c = 'Partner')); }
        }
        for (AggregateResult ar : [
            SELECT Subscription__r.Account__c AccountId, SUM(Status_Active_Device__c) ActDvc, SUM(Status_Active_Service__c) ActSvc, 
            SUM(Status_Past_Customer__c) CuPast, SUM(Status_Future_Customer__c) CuFutr 
            FROM SubscriptionLineItem__c WHERE Subscription__r.Account__c IN :sObjectMap.keySet() GROUP BY Subscription__r.Account__c
        ]){
            SubbedAccts.add((String)ar.get('AccountId'));
            Boolean ActDvc = (Decimal)ar.get('ActDvc') != 0;
            Boolean ActSvc = (Decimal)ar.get('ActSvc') != 0;
            Boolean CuPast = (Decimal)ar.get('CuPast') != 0;
            Boolean CuFutr = (Decimal)ar.get('CuFutr') != 0;
            Boolean Inactv = (Decimal)(sObjectMap.get((String)ar.get('AccountId')).get('Number_of_Active_Subscriptions_2__c')) == 0;
            Boolean Legacy = (String)(sObjectMap.get((String)ar.get('AccountId')).get('NS_Customer_Internal_ID__c')) != null;
            String Status = 'Hardware Customer';
            if ((ActDvc && ActSvc) || (CuPast && CuFutr)) { Status = 'Active Customer';
            } else if (!ActDvc && ActSvc) { Status = 'Paused Customer';
            } else if (ActDvc && !ActSvc) { Status = 'Incomplete Customer';
            } else if (CuPast) { Status = 'Lost Customer';
            } else if (CuFutr) { Status = 'Future Customer';
			} else if (Inactv) { Status = 'Lost Hardware Customer'; }
            if (Status != (String)(sObjectMap.get((String)ar.get('AccountId')).get('Account_Status__c'))) {
                UpdateAccounts.add(new Account(Id = (String)ar.get('AccountId'),Account_Status__c = Status));
            }
        }
        for (Account acct : [
            SELECT Id, Account_Status__c, NS_Customer_Internal_ID__c, Product_Test_Participation__c, (SELECT Id, StageName FROM Opportunities WHERE StageName != 'Closed Won' ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :sObjectMap.keySet() AND Id NOT IN :SubbedAccts
        ]) {
            if (acct.Product_Test_Participation__c != null) { UpdateAccounts.add(new Account(Id = acct.Id,Account_Status__c = 'Product Test Only')); } else {
                String AcctStat = 'Prospect';
                if (acct.Opportunities.size() == 1) AcctStat += ' (' + acct.Opportunities[0].StageName + ')';
                if (AcctStat == 'Prospect' && acct.NS_Customer_Internal_ID__c != null) AcctStat = 'Legacy NetSuite Customer';
                if (acct.Account_Status__c != AcctStat) UpdateAccounts.add(new Account(Id = acct.Id,Account_Status__c = AcctStat)); 
            }
        }
        update UpdateAccounts;
    }
}