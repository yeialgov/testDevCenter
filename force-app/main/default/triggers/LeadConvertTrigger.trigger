trigger LeadConvertTrigger on Lead (before update) {
       
    Map<Id,Id> IdMap = new Map<Id,Id>();
    
    for (Lead Lead : Trigger.new) {
        if (Lead.isConverted) IdMap.put(Lead.ConvertedOpportunityId, Lead.Id);
    }
    
    List<Opportunity> Opportunities = [SELECT Id, Converted_Lead__c FROM Opportunity WHERE Converted_Lead__c = null AND Id IN :IdMap.keySet()];
    for (Opportunity Opportunity : Opportunities) {
        Opportunity.Converted_Lead__c = IdMap.get(Opportunity.Id);
    }
    update Opportunities;
    
    DateTime LastMinute = DateTime.now().addMinutes(-1);
    Map<Id, Opportunity> OppMap = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id IN :IdMap.keySet() AND CreatedDate >= :LastMinute]);

    for (Lead Lead : Trigger.new) {
        if (Lead.isConverted && Lead.MetroOpportunityId__c != null && !OppMap.keySet().contains(Lead.ConvertedOpportunityId)) Lead.addError('Lead with Metro Opportunity Id cannot be converted without a new Opportunity.');
    }
        
}