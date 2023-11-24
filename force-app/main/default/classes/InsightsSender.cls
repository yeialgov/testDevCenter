global class InsightsSender implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global InsightsSender() {
        Query = 'SELECT Id, VenueName__c, InsightsEmail__c, InsightsVersion__c, InsightsUnsubbed__c, InsightsResubbed__c, Account__r.Name, Account__r.CurrencyIsoCode, Account__r.PrimaryLanguage__c FROM MyObVenue__c WHERE InsightsEmail__c != null AND (InsightsUnsubbed__c = FALSE OR InsightsResubbed__c = TRUE) AND Id IN (SELECT Venue_SFId__c FROM DataInsight__c WHERE Calculation_Timestamp__c = TODAY)';
    }
    
    global InsightsSender(Boolean IsTestParam) {
        IsTest = IsTestParam;
        Query = 'SELECT Id, VenueName__c, InsightsEmail__c, InsightsVersion__c, InsightsUnsubbed__c, InsightsResubbed__c, Account__r.Name, Account__r.CurrencyIsoCode, Account__r.PrimaryLanguage__c, Channel__c FROM MyObVenue__c WHERE InsightsEmail__c != null AND (InsightsUnsubbed__c = FALSE OR InsightsResubbed__c = TRUE) AND Id IN (SELECT Venue_SFId__c FROM DataInsight__c WHERE Calculation_Timestamp__c = TODAY)';
    }
    
    global InsightsSender(String VenueWhereClause, String CalcDay) {
        Query = 'SELECT Id, VenueName__c, InsightsEmail__c, InsightsVersion__c, InsightsUnsubbed__c, InsightsResubbed__c, Account__r.Name, Account__r.CurrencyIsoCode, Account__r.PrimaryLanguage__c, Channel__c FROM MyObVenue__c WHERE InsightsEmail__c != null AND (InsightsUnsubbed__c = FALSE OR InsightsResubbed__c = TRUE) AND Id IN (SELECT Venue_SFId__c FROM DataInsight__c WHERE Calculation_Timestamp__c = ' + CalcDay + ') ' + VenueWhereClause;
    }
    
    global Boolean IsTest = false;
    
    global String Query;
    
    global KpiController kpic = new KpiController();
            
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String,String> VersionMap = new Map<String,String>{null=>'d-aabe263987f2446c9dd85e72b4e5b801','2'=>'d-858b316349894415a69386dc97688a53'};
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        Map<Id, List<Map<String,Object>>> kpiMap = new Map<Id, List<Map<String,Object>>>();
        Map<String,Map<Id, sObject>> VenueMap = new Map<String,Map<Id, sObject>>();
        Map<Id, String> LanguageMap = new Map<Id, String>();
        Map<Id, String> CurrencyMap = new Map<Id, String>();
        List<SectionWrapper> Sections = new List<SectionWrapper>();
        Set<String> NoDupes = new Set<String>();
        Set<String> ResubAddresses = new Set<String>();
        for(sObject s : scope){
            if ((Boolean)s.get('InsightsResubbed__c')) {
                ResubAddresses.add((String)s.get('InsightsEmail__c'));
                s.put('InsightsResubbed__c', false);
                s.put('InsightsUnsubbed__c', false);
            }
            kpiMap.put((Id)s.get('Id'), new List<Map<String,Object>>());
            if (VenueMap.get(VersionMap.get((String)s.get('InsightsVersion__c'))) == null) VenueMap.put(VersionMap.get((String)s.get('InsightsVersion__c')), new Map<Id, sObject>());
            VenueMap.get(VersionMap.get((String)s.get('InsightsVersion__c'))).put((Id)s.get('Id'), s);
            String lang = (String)s.getSObject('Account__r').get('PrimaryLanguage__c');
            LanguageMap.put((Id)s.get('Id'), lang == 'English' ? lang : 'German');
            CurrencyMap.put((Id)s.get('Id'), (String)s.getSObject('Account__r').get('CurrencyIsoCode'));
        }
        Integer calloutPairs = 0;
        for (String ResubAddress : ResubAddresses) {
            if (calloutPairs < 49) {
                //global re-sub
                calloutPairs++;
                HttpRequest globalUnsubReq = new HttpRequest();
                globalUnsubReq.setMethod('DELETE');
                globalUnsubReq.setEndpoint('https://api.sendgrid.com/v3/asm/suppressions/global/' + ResubAddress);
                globalUnsubReq.setHeader('content-type', 'application/json');
                globalUnsubReq.setHeader('Authorization', 'Bearer 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');
                Http globalUnsubHttp = new Http();
                HTTPResponse globalUnsubRes = globalUnsubHttp.send(globalUnsubReq);
                //group re-sum
                HttpRequest groupUnsubReq = new HttpRequest();
                groupUnsubReq.setMethod('DELETE');
                groupUnsubReq.setEndpoint('https://api.sendgrid.com/v3/asm/groups/20248/suppressions/' + ResubAddress);
                groupUnsubReq.setHeader('content-type', 'application/json');
                groupUnsubReq.setHeader('Authorization', 'Bearer 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');
                Http groupUnsubHttp = new Http();
                HTTPResponse groupUnsubRes = groupUnsubHttp.send(groupUnsubReq);
            }
        }
        for (DataInsight__c DI : [
            SELECT Id, Relevance__c, Venue_SFId__c, Metric__c, Value__c, Version__c, Venue_SFId__r.Account__r.PrimaryLanguage__c, Venue_SFId__r.Account__r.CurrencyIsoCode, Venue_SFId__r.InsightsVersion__c
            FROM DataInsight__c
            WHERE Calculation_Timestamp__c = TODAY AND Venue_SFId__c IN :kpiMap.keySet()
        ]) {
            if (!NoDupes.contains(DI.Venue_SFId__c+DI.Metric__c)) {
            	Sections.add(new SectionWrapper(this, DI, LanguageMap.get(DI.Venue_SFId__c), CurrencyMap.get(DI.Venue_SFId__c))); 
                NoDupes.add(DI.Venue_SFId__c+DI.Metric__c);
            }
        }
        Sections.sort();
        for (SectionWrapper SW : Sections) {
            try{
                if (
                    SW.MetricName == 'Revenue Watermark' 
                    && kpiMap.get(SW.VenueId).size() == 1
                ) {
                    SW.kpi = kpic.process(SW, kpiMap.get(SW.VenueId)[0]);
                    kpiMap.put(SW.VenueId, new List<Map<String,Object>>());
                }
            } catch(exception e){}
            system.debug(json.serialize(SW));
            Boolean needsLegend = false;
            Boolean movesLegend = false;
            try {
                if (SW.Version != null && SW.Version != '1' && (String)((SW.kpi).get('widthClass')) == 'optCol') {
                    Integer kpiIndex = kpiMap.get(SW.VenueId).size()-1;
                    while (kpiIndex >= 0) {
                        try {
                            if ((Boolean)((kpiMap.get(SW.VenueId))[kpiIndex]).get('isKpi')) { break; } else { kpiIndex--; }
                        } catch(exception ee) {
                            if ((kpiMap.get(SW.VenueId))[kpiIndex].get('isLegend') != null) { break; }
                            kpiIndex--; 
                        }
                    }
                    if (kpiIndex >= 0) {
                        if ((String)(kpiMap.get(SW.VenueId)[kpiIndex]).get('widthClass') == 'optCol' && !(SW.kpi.get('isTopItem') != null)) {
                            // both become half
                            SW.kpi.put('widthClass', 'halfCol');
                            kpiMap.get(SW.VenueId)[kpiIndex].put('widthClass', 'halfCol');
                        } else if ((String)((kpiMap.get(SW.VenueId))[kpiIndex]).get('widthClass') == 'halfCol' && !(SW.kpi.get('isTopItem') != null)) {
                            // this becomes full
                            SW.kpi.put('widthClass', 'fullCol');
                        } else if (SW.kpi.get('isTopItem') != null && (kpiMap.get(SW.VenueId)[kpiIndex]).get('isLegend') != null) {
                            movesLegend = true;
                            SW.kpi.put('widthClass', 'halfCol');
                            kpiMap.get(SW.VenueId)[kpiIndex-1].put('widthClass', 'halfCol');
                        } else if (SW.kpi.get('isTopItem') != null) {
                            needsLegend = true;
                        }
                    }
                }
            } catch(exception e){}
            if (movesLegend) kpiMap.get(SW.VenueId).remove(kpiMap.get(SW.VenueId).size()-1);
            kpiMap.get(SW.VenueId).add(SW.kpi);
            if (needsLegend || movesLegend) kpiMap.get(SW.VenueId).add((Map<String, Object>)JSON.deserializeUntyped('{"isLegend":true,"widthClass":"fullCol"}'));
        }
        List<EmailWrapper> EWs = new List<EmailWrapper>();
        for (String VersionId : VersionMap.keySet()) {
            try{EWs.add(new EmailWrapper(VersionMap.get(VersionId), VersionId, VenueMap.get(VersionMap.get(VersionId)), kpiMap, LanguageMap));}catch(exception e){}
        } 
        for (EmailWrapper EW : EWs) {
            String jsonBody = json.serialize(EW).replace('_x','');
            system.debug(jsonBody);
            if (!IsTest) {
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint('https://api.sendgrid.com/v3/mail/send');
                req.setTimeout(120000);
                req.setHeader('content-type', 'application/json');
                req.setHeader('Authorization', 'Bearer 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');
                req.setBody(jsonBody);
                Http http = new Http();
                if (!test.isRunningTest()) {
                    try {
                        HTTPResponse res = http.send(req);
                        system.debug(res.getBody());
                        system.debug(res.getStatus());
                        system.debug(res.getStatusCode());
                    } catch (System.CalloutException e) {
                        System.debug(LoggingLevel.ERROR, e.getMessage());
                    }
                }
                update scope;
            } else { system.debug('Emails not sent: TEST ONLY'); }
        }
    }
    
    global class EmailWrapper {
        public String template_id { get; set; }
        public List<String> categories { get; set; }
        public AsmWrapper asm { get; set; }
        public List<PersonalizationWrapper> personalizations { get; set; }
        public FromWrapper from_x { get; set; }
        public FromWrapper reply_to { get; set; }
        public EmailWrapper(String TemplateId, String TemplateVersion, Map<Id, sObject> VenueMap, Map<Id, List<Map<String,Object>>> kpiMap, Map<Id, String> LanguageMap) {
            template_id = TemplateId;
            categories = new List<String>{'insights_daily', 'insights_v' + TemplateVersion == null ? '0' : TemplateVersion};
            asm = new AsmWrapper(20248);
            from_x = new FromWrapper();
            reply_to = new FromWrapper();
            personalizations = new List<PersonalizationWrapper>();
            system.debug(json.serialize(VenueMap));
            for (Id VenueId : VenueMap.keySet()) {
                personalizations.add(new PersonalizationWrapper(VenueMap.get(VenueId), kpiMap.get(VenueId), LanguageMap.get(VenueId)));
            }
        }
    }
    
    global class AsmWrapper {
        public Integer group_id;
        public AsmWrapper(Integer i) { group_id = i; }
    }
    
    global class PersonalizationWrapper {
        public List<ToWrapper> to { get; set; }
        public String subject { get; set; }
        public DTDWrapper dynamic_template_data { get; set; }
        public PersonalizationWrapper(sObject s, List<Map<String,Object>> kpis, String Language) {
            to = new List<ToWrapper>{new ToWrapper(s)};
            subject = 'Insights ' + (Language == 'English' ? 'for ' : 'für den ') + Date.today().addDays(-1).format();
            dynamic_template_data = new DTDWrapper(kpis, s, subject, Language == 'English');
        }
    }
    
    global class DTDWrapper {
        public List<Map<String,Object>> kpi { get; set; }
        public String Heading { get; set; }
        public String SubHeading { get; set; }
        public Boolean isEnglish { get; set; }
        public DTDWrapper(List<Map<String,Object>> kpis, sObject s, String subHeadingText, Boolean plEnglish) {
            kpi = kpis;
            Heading = (String)s.get('VenueName__c');
            SubHeading = subHeadingText;
            isEnglish = plEnglish;
        }
    }
    
    global class ToWrapper {
        public String email { get; set; }
        public ToWrapper(sObject s) {
            email = (String)s.get('InsightsEmail__c');
        }
    }
    
    global class FromWrapper {
        public String email { get; set; }
        public String name { get; set; }
        public FromWrapper() {
            email = 'insights@orderbird.com';
            name = 'orderbird Insights';
        }
    }

    global class SectionWrapper implements Comparable {
        public InsightsSender Parent { get; set; }
        public Double Ranker { get; set; }
        public Id VenueId { get; set; }
        public String MetricName { get; set; }
        public String Language { get; set; }
        public String CurrCode { get; set; }
        public String Version { get; set; }
        public Map<String, Object> Value { get; set; }
        public Map<String, Object> kpi { get; set; }
        global SectionWrapper(InsightsSender is, DataInsight__c DI, String Lang, String Curr) {
            Parent = is;
            MetricName = DI.Metric__c;
            Ranker = DI.Relevance__c;
            Version = DI.Venue_SFId__r.InsightsVersion__c;
            if (MetricName == 'Revenue') Ranker = 5.0;
            if (MetricName == 'Revenue Watermark') Ranker = 4.0;
            Language = Lang;
            CurrCode = Curr;
            VenueId = DI.Venue_SFId__c;
            Boolean Okay = true;
            try {
                Value = (Map<String, Object>)JSON.deserializeUntyped(DI.Value__c);
            } catch(exception e) {
                try {
                    Value = new Map<String, Object>();
                    Value.put('Value', (Object)JSON.deserializeUntyped(DI.Value__c == null ? '0' : DI.Value__c));
                }catch(exception ee){Okay = false;}
            }
            if (Okay) kpi = Parent.kpic.process(this);
        }
        public Integer compareTo(Object compareTo) {
            SectionWrapper compareToSW = (SectionWrapper)compareTo;
            if (Ranker == compareToSW.Ranker) return 0;
            if (Ranker > compareToSW.Ranker) return -1;
            return 1;        
        }
    }
    
    
    global void finish(Database.BatchableContext BC){
    }
    
}