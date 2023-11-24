global class InsightsSubscription implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext SC) {
        futureExecute();
    }
    
    @future(callout=true)
    global static void futureExecute() {
        
        //subscribe venues to Insights (limit 200)
        
        List<MyObVenue__c> SubscribeVenues = [
        	SELECT Id, InsightsEmail__c, InsightsVersion__c, Account__r.PrimaryLanguage__c, Account__r.Primary_Contact__r.Email
            FROM MyObVenue__c
            WHERE Id IN (SELECT Venue_SFId__c from DataInsight__c) AND InsightsEligible__c = TRUE
            LIMIT 200
        ];
        
		List<SendGrid.PersonalizationWrapper> PWs = new List<SendGrid.PersonalizationWrapper>();       
        
        for (MyObVenue__c v : SubscribeVenues) {
            v.InsightsEmail__c = v.Account__r.Primary_Contact__r.Email;
            v.InsightsVersion__c = '2';
            PWs.add(new SendGrid.PersonalizationWrapper(v.InsightsEmail__c, (Map<String, Object>)JSON.deserializeUntyped ('{"isEnglish":' + String.valueOf(v.Account__r.PrimaryLanguage__c == 'English') + '}')));
        }
                
        SendGrid.SendEmail(new SendGrid.EmailWrapper(
            'd-ab85a9551dc0422181279d0748c96e7a', 	//templateId
            new List<String>{'insights_presend'},	//categories
            PWs,									//personalizations
            20248									//asm (unsubscribe group)
        ));
        
        ////////////
        // retrieve globally unsubscribed email addresses
        
        HttpRequest globalUnsubReq = new HttpRequest();
        globalUnsubReq.setMethod('GET');
        globalUnsubReq.setEndpoint('https://api.sendgrid.com/v3/suppression/unsubscribes?start_time=' + String.valueOf(Date.newInstance(1970,1,4).daysBetween(Date.today())*86400));
        globalUnsubReq.setHeader('content-type', 'application/json');
        globalUnsubReq.setHeader('Authorization', 'Bearer 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');
        Http globalUnsubHttp = new Http();
        HTTPResponse globalUnsubRes;
        if (!test.isRunningTest()) globalUnsubRes = globalUnsubHttp.send(globalUnsubReq);

        List<Object> GlobalUnsubs;
        try {
            GlobalUnsubs = (List<Object>)json.deserializeUntyped(globalUnsubRes.getBody());
        }catch(exception e){
            GlobalUnsubs = new List<Object>();
        }
        
        ////////////
        // retrieve group unsubscribed email addresses
        
        HttpRequest groupUnsubReq = new HttpRequest();
        groupUnsubReq.setMethod('GET');
        groupUnsubReq.setEndpoint('https://api.sendgrid.com/v3/asm/groups/20248/suppressions');
        groupUnsubReq.setHeader('content-type', 'application/json');
        groupUnsubReq.setHeader('Authorization', 'Bearer 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');
        Http groupUnsubHttp = new Http();
        HTTPResponse groupUnsubRes;
        if (!test.isRunningTest()) groupUnsubRes = groupUnsubHttp.send(groupUnsubReq);
        Set<String> UnsubbedEmails;
        try {
            UnsubbedEmails = (Set<String>)json.deserialize(groupUnsubRes.getBody(), Set<String>.class);
        }catch(exception e){
            UnsubbedEmails = new Set<String>();
        }
        for (Object o : GlobalUnsubs) {
            Map<String,Object> GlobalUnsubMap = (Map<String,Object>)o;
            UnsubbedEmails.add((String)GlobalUnsubMap.get('email'));
        }
        List<MyObVenue__c> VenuesToUnsub = [SELECT Id, InsightsUnsubbed__c FROM MyObVenue__c WHERE InsightsEmail__c != null AND InsightsEmail__c IN :UnsubbedEmails];
        for (MyObVenue__c v : VenuesToUnsub) {
            v.InsightsUnsubbed__c = true;
        }
        update VenuesToUnsub;
        update SubscribeVenues;

    }
}