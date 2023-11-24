public class DOI_Sync implements Queueable {
    
    public Static Map<String, Integer> StatusTiers = new Map<String, Integer>{
        'Confirmed' => 0, 'Refused' => 0, 'Verbal Ok' => 0, 'Implied' => 1, 'Pending' => 2, 'No' => 3, null => 4
    };
        
    public DOI_Sync() {
    }
    
    public void execute(QueueableContext context) {
        
        Set<String> Emails = new Set<String>();
        Map<String, List<Wrapper>> WrapperMap = new Map<String, List<Wrapper>>();
        List<Contact> updateContacts = new List<Contact>();
        List<Lead> updateLeads = new List<Lead>();
        
        for (AggregateResult ar : [SELECT Email, COUNT(Id) FROM Contact WHERE TS_Marketing_Opt_In_Update__c >= YESTERDAY AND Email != null AND Email != 'na@na.de' GROUP BY Email HAVING COUNT(Id) < 200 ORDER BY MAX(TS_Marketing_Opt_In_Update__c) DESC LIMIT 2000]) {
            Emails.add((String)ar.get('Email'));
        }
        for (AggregateResult ar : [SELECT Email, COUNT(Id) FROM Contact WHERE CreatedDate >= YESTERDAY AND Email != null AND Email != 'na@na.de' GROUP BY Email HAVING COUNT(Id) < 200 ORDER BY MAX(CreatedDate) DESC LIMIT 2000]) {
            Emails.add((String)ar.get('Email'));
        }
        for (AggregateResult ar : [SELECT Email, COUNT(Id) FROM Lead WHERE TS_Marketing_Opt_In_Update__c >= YESTERDAY AND Email != null AND Email != 'na@na.de' GROUP BY Email HAVING COUNT(Id) < 200 ORDER BY MAX(TS_Marketing_Opt_In_Update__c) DESC LIMIT 2000]) {
            Emails.add((String)ar.get('Email'));
        }
        for (AggregateResult ar : [SELECT Email, COUNT(Id) FROM Lead WHERE CreatedDate >= YESTERDAY AND Email != null AND Email != 'na@na.de' GROUP BY Email HAVING COUNT(Id) < 200 ORDER BY MAX(CreatedDate) DESC LIMIT 2000]) {
            Emails.add((String)ar.get('Email'));
        }
        
        for (Lead l : [
            SELECT Id, Email, DoubleOptIn__c, TS_Marketing_Opt_In_Update__c, CreatedDate, LAC_Lookup__r.Marketing_Opt_In_Implied__c, IsConverted 
            FROM Lead WHERE Email IN :Emails
        ]) {
            if (WrapperMap.get(l.Email) == null) WrapperMap.put(l.Email, new List<Wrapper>());
            WrapperMap.get(l.Email).add( new Wrapper(l) );
        }
        for (Contact c : [
            SELECT Id, Email, DoubleOptIn__c, TS_Marketing_Opt_In_Update__c, CreatedDate
            FROM Contact WHERE Email IN :Emails
        ]) {
            if (WrapperMap.get(c.Email) == null) WrapperMap.put(c.Email, new List<Wrapper>());
            WrapperMap.get(c.Email).add( new Wrapper(c) );
        }
        
        for (String Email : Emails) {
            WrapperMap.get(Email).sort();
            String Status = WrapperMap.get(Email)[0].Status;
            if (Status == 'Verbal Ok' && WrapperMap.get(Email).size() > 1) {
                for (Integer x=1; x<WrapperMap.get(Email).size(); x++) {
                    if (WrapperMap.get(Email)[x].Status != 'Verbal Ok') {
                        if (WrapperMap.get(Email)[x].Status == 'Confirmed') Status = 'Confirmed';
                    }
                }
            }
            system.debug(Email + '|' + Status);
            for (Wrapper w : WrapperMap.get(Email)) {
                if (w.Status != Status || w.StatusChange) {
                    if (w.IsLead) {
                        if (updateLeads.size() < 200 && !w.IsConvertedLead) updateLeads.add(new Lead(Id = w.Id, DoubleOptIn__c = Status));
                    } else {
                        if (updateContacts.size() < 200) updateContacts.add(new Contact(Id = w.Id, DoubleOptIn__c = Status));
                    }
                }
            }
        }
        
		system.debug(json.serialize(updateLeads));        
		system.debug(json.serialize(updateContacts));        
        
        update updateLeads;
        update updateContacts;
    }
    
    public class Wrapper implements Comparable {
        public String Status;
        public Integer Tier;
        public DateTime TS;
        public String Id;
        public Boolean IsLead;
        public Boolean IsConvertedLead;
        public Boolean StatusChange;
        
        public Wrapper(Lead l) {
            Id = l.Id;
            IsLead = true;
            IsConvertedLead = l.IsConverted;
            StatusChange = false;
            Status = l.DoubleOptIn__c;
            Tier = StatusTiers.get(Status);
            if (Tier > StatusTiers.get('Implied') && l.LAC_Lookup__r.Marketing_Opt_In_Implied__c) {
                Status = 'Implied';
                StatusChange = true;
                Tier = StatusTiers.get(Status);
            }
            TS = l.TS_Marketing_Opt_In_Update__c;
            if (TS == null) TS = l.CreatedDate;
        }
        
        public Wrapper(Contact c) {
            Id = c.Id;
            IsLead = false;
            IsConvertedLead = false;
            StatusChange = false;
            Status = c.DoubleOptIn__c;
            Tier = StatusTiers.get(Status);
            TS = c.TS_Marketing_Opt_In_Update__c;
            if (TS == null) TS = c.CreatedDate;
        }
        
        public Integer compareTo(Object compareTo) {
            Wrapper compWrap = (Wrapper)compareTo;
            if (Tier < compWrap.Tier) return -1;
            if (Tier > compWrap.Tier) return 1;
            if (TS > compWrap.TS) return -1;
            return 1;
        }
    }
    
}