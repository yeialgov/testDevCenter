global class DunningBatch implements Database.Batchable<sObject>{
    
    global String Query;
    global Integer BatchNo;
    global String DebtCollectionEmail;
    global String DebtCollectionEmailCC;
    global OrgWideEmailAddress[] owea;
    global Map<String,Id> templateMap;

    /****
    **
    ** This is designed to have four batches run...
    ** 0: Accounts that are 10-19 days overdue
    ** 1: Accounts that are 20-29 days overdue
    ** 2: Accounts that are 30 or more days overdue
    ** 3: Accounts that are not 10 or more days overdue but are in Dunning process
    **
    ** refer to JIRA ticket CDS-203
    **
    ****/

    global DunningBatch(Integer inpBatchNo) {
        BatchNo = inpBatchNo;
        Integer LowerLimit = BatchNo * 10 + 10;
        Integer UpperLimit = LowerLimit + 10;
        Id SysAdminId = [SELECT Id FROM Profile where Name = 'System Administrator' LIMIT 1].Id;
        DebtCollection__c dc = DebtCollection__c.getInstance(SysAdminId);
        Query  =            'SELECT Id, ';
        Query +=            '  SF_BillTo_Contact__c, ';                             // emails will be sent to Billing Contact
        Query +=            '  Dunning_0_Date__c, ';
        Query +=            '  Dunning_1_Date__c, ';
        Query +=            '  Dunning_2_Date__c, ';
        Query +=            '  Dunning_Status__c, ';
        Query +=            '  Closed_Contract_Paid_Date__c, ';
        Query +=            '  Target_Product__c ';
        Query +=            'FROM Account ';
        Query +=            'WHERE RecordType.Name = \'Customer\' AND SF_BillTo_Contact__r.Email != null ';
        if (BatchNo == 0) Query += ' AND Dunning_Status__c != \'Friendly Reminder\' ';
        if (BatchNo == 1) Query += ' AND Dunning_Status__c != \'1st Dunning\' ';
        if (BatchNo == 2) Query += ' AND Dunning_Status__c != \'2nd Dunning\' ';
        if (!test.isRunningTest() && BatchNo != 3) {
            Query +=        '  AND Account_Balance_2__c >= 39 ';
            Query +=        '  AND Combined_Balance__c >= 39 ';
        }
        Query +=            '  AND Dunning_Status__c != \'Closed\' ';               // accounts with Dunning_X_Date are exempted 
        Query +=            '  AND SF_BillTo_Contact__r.IsEmailBounced = FALSE ';
        if (BatchNo < 3) {
            Query +=        '  AND Dunning_0_Date__c != LAST_n_DAYS:9 ';            //
            Query +=        '  AND Dunning_1_Date__c != LAST_n_DAYS:20 ';           // 10/14 days must pass between stages
            Query +=        '  AND Dunning_2_Date__c != LAST_n_DAYS:30 ';           //
            Query +=        '  AND Id IN ( ';
            Query +=        '    SELECT Account__c  ';
            Query +=        '    FROM Invoice__c  ';                        		// has an invoice that is older 
            Query +=        '    WHERE Days_Overdue__c >= ';                        // than the lower limit
            Query +=               String.valueOf(LowerLimit); 
            Query +=        '      AND Balance__c >= 10 ';
            if (BatchNo < 2) {
                Query +=    '  ) AND Id NOT IN ( ';                                 // for Batch 0 and 1, does NOT have an invoice
                Query +=    '    SELECT Account__c  ';                       		// that is older than the upper limit
                Query +=    '    FROM Invoice__c  ';
                Query +=    '    WHERE Days_Overdue__c >= '; 
                Query +=           String.valueOf(UpperLimit); 
                Query +=    '      AND Balance__c >= 10 ';
            }
        }
        if (BatchNo == 3) {
            Query +=        '  AND Dunning_Status__c != \'Not in Dunning\' ';		// Batch 3 is looking for accounts that
            Query +=        '  AND Id NOT IN ( ';                                   // do NOT have any invoices 10 days overdue
            Query +=        '    SELECT Account__c';
            Query +=        '    FROM Invoice__c';
            Query +=        '    WHERE Days_Overdue__c >= 10';
            Query +=		'  ) AND Id NOT IN (';
            Query +=		'    SELECT Account__c';
            Query +=        '    FROM Refund__c';
            Query +=        '    WHERE CreatedDate = LAST_n_DAYS:8';
        }
        Query +=            '  ) ';
        if (!Test.isRunningTest()) {
            //Query += 'LIMIT ';
            if (BatchNo == 2) {
                Query += ' LIMIT ';
                Query += dc.BatchLimit__c;
                //} else {
                //    Query += '10';
            }
        }

        // find NoReply email address to send from
        owea = [select Id from OrgWideEmailAddress where Address = 'dunning@orderbird.com'];

        // create map to lookup email template IDs by string (named according to dunning stage)
        templateMap = new Map<String,Id>();
        for (EmailTemplate et : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'Dunning_obet_%']) {
            templateMap.put(et.DeveloperName, et.Id);
        }
        DebtCollectionEmail = dc.Email__c;
        DebtCollectionEmailCC = dc.EmailCC__c;
        if (test.isRunningTest()) DebtCollectionEmail = 'dunning@orderbird.com';
        if (test.isRunningTest()) DebtCollectionEmailCC = 'dunning@orderbird.com';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        // create list of emails to send at the end of the process
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        
        // iterate through queried accounts
        for (SObject s : scope) {

            // assign values for each dunning stage (see map below for values)
            Integer DunningStatus = mapDunningStatus.get((String)s.get('Dunning_Status__c'));
            // only PRO Customers should go in Dunning process
            Boolean IsMINI = (String)s.get('Target_Product__c') == 'MINI';	
            /* keep PRO Customers who have been subscribed and 
             * never technically became a true paying customer out of dunning.*/
            Boolean HasCCPD = (Date)s.get('Closed_Contract_Paid_Date__c') != null;  
            
            if (BatchNo == 0) {	
                if (DunningStatus == 1) {
                    s.put('Dunning_1_Date__c', null);           // clear D1 date if in D1 status but in D0 overdue range
                } else if (DunningStatus == 2) {
                    s.put('Dunning_1_Date__c', null);           // clear D1 date if in D2 status but in D0 overdue range
                    s.put('Dunning_2_Date__c', null);           // clear D2 date if in D2 status but in D0 overdue range
                } else if (DunningStatus == 3) {
                    s.put('Dunning_0_Date__c', Date.today());   // add D0 date if no D status but in D0 overdue range
                    if (HasCCPD) Emails.add(addEmail(s,0));                  // add D0 email to be sent
                }

            } else if (BatchNo == 1) {
                if (DunningStatus == 0) {
                    s.put('Dunning_1_Date__c', Date.today());   // add D1 date if in D0 status but in D1 overdue range
                    if (HasCCPD) Emails.add(addEmail(s,1));                  // add D1 email to be sent
                } else if (DunningStatus == 2) {
                    s.put('Dunning_2_Date__c', null);           // clear D2 date if in D2 status but in D1 overdue range
                } else if (DunningStatus == 3) {
                    s.put('Dunning_0_Date__c', Date.today());   // add D0 date if no D status but in D1 overdue range
                    if (HasCCPD) Emails.add(addEmail(s,0));                  // add D0 email to be sent
                }
            } else if (BatchNo == 2) {
                if (DunningStatus == 0) {
                    s.put('Dunning_1_Date__c', Date.today());   // add D1 date if in D0 status but in D2 overdue range
                    if (HasCCPD) Emails.add(addEmail(s,1));                  // add D1 email to be sent
                } else if (DunningStatus == 1 && HasCCPD ) {    
                    s.put('Dunning_2_Date__c', Date.today());   // add D2 date if in D1 status but in D2 overdue range
                    system.debug('flag1');
                    if (HasCCPD && !IsMINI) {
                        Emails.add(addEmail(s,2,DebtCollectionEmail, DebtCollectionEmailCC)); // add D2 email to be sent
                        system.debug('flag2');
                    }
                } else if (DunningStatus == 3) {
                    s.put('Dunning_0_Date__c', Date.today());   // add D0 date if no D status but in D2 overdue range
                    if (HasCCPD) Emails.add(addEmail(s,0));                  // add D0 email to be sent
                }
            } else if (BatchNo == 3) {
                s.put('Dunning_0_Date__c', null);               //
                s.put('Dunning_1_Date__c', null);               // clear date fields to reset status
                s.put('Dunning_2_Date__c', null);               //
            }
        }
        update scope;
        if (test.isRunningTest()){
            system.debug('Sending emails flag');
        }else {
            Messaging.sendEmail( Emails );
        }  
    }

    public static Map<String,Integer> mapDunningStatus = new Map<String,Integer>{
        'Friendly Reminder' => 0,
        '1st Dunning' => 1,
        '2nd Dunning' => 2,
        'Not in Dunning' => 3,
        'Closed' => 4
    };

    // create email
    public Messaging.SingleEmailMessage addEmail(sObject s, Integer templateNumber) {
        Id templateId = templateMap.get('Dunning_obet_' + String.valueOf(templateNumber));
        Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
        em.setTemplateId(templateId);
        em.setTargetObjectID((Id)s.get('SF_BillTo_Contact__c'));
        em.setWhatId((Id)s.get('Id'));
        em.setSaveAsActivity(false);
        em.setToAddresses( new List<String>{} );
        em.setBccAddresses( new List<String>{'dunning@orderbird.com'} );
        em.setOrgWideEmailAddressId(owea.get(0).Id);
        return em;
    }
    
    // create email - INTERWEGA
    public Messaging.SingleEmailMessage addEmail(sObject s, Integer templateNumber, String emailAddress, String emailAddressCC) {
        Id templateId = templateMap.get('Dunning_obet_' + String.valueOf(templateNumber));
        Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
        em.setTemplateId(templateId);
        em.setTargetObjectID((Id)s.get('SF_BillTo_Contact__c'));
        em.setTreatTargetObjectAsRecipient(false);
        em.setWhatId((Id)s.get('Id'));
        em.setSaveAsActivity(false);
        em.setToAddresses( new List<String>{ emailAddress } );
        if (emailAddressCC != null) em.setCcAddresses( new List<String>{ emailAddressCC } );
        em.setBccAddresses( new List<String>{'dunning@orderbird.com'} );
        em.setOrgWideEmailAddressId(owea.get(0).Id);
        return em;
    }
    
    global void finish(Database.BatchableContext BC){}
    
}