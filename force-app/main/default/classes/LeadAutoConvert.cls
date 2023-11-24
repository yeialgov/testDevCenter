/**
 * @author incubes
 */
global without sharing class LeadAutoConvert {
	global static void convert(List<Lead> leads) {
        convert(leads, null); 
    }
    global static void convert(List<Lead> leads, Set<Id> setDoNotCreateOpportunities) {
        convert(leads, setDoNotCreateOpportunities, null, null, null);
    }
    global static List<Lead> convert(List<Lead> leads, Set<Id> setDoNotCreateOpportunities, Schema.sObjectField accountLookupField, Schema.sObjectField contactLookupField, Schema.sObjectField opportunityLookupField) {
        if (leads == null || leads.size() < 1) return leads; 
        if (setDoNotCreateOpportunities == null) setDoNotCreateOpportunities = new Set<Id>(); 
        Integer counter = 0; 
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        List<List<Database.LeadConvert>> leadConvertsBatch = new List<List<Database.LeadConvert>>();  
		List<Lead> result = new List<Lead>(); 
        for (Lead lead : leads) {
            if (leadConvertsBatch.size() < (counter/100)+1)
                leadConvertsBatch.add(new List<Database.LeadConvert>()); 
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(lead.Id);
            leadConvert.convertedStatus = lead.Status; 
            leadConvert.setDoNotCreateOpportunity(setDoNotCreateOpportunities.contains(lead.Id));
            leadConvertsBatch[counter/100].add(leadConvert);             
            counter++; 
            if (lead.Id != null) leadsMap.put(lead.Id, lead); 
        }
        for (List<Database.LeadConvert> leadConverts : leadConvertsBatch) {
            Database.LeadConvertResult[] leadConvertResults = Database.convertLead(leadConverts, false); 
            for (Database.LeadConvertResult leadConvertResult : leadConvertResults) 
                if (leadConvertResult.isSuccess() != true) { 
                    String[] errors = new List<String>(); 
                    for (Database.Error error : leadConvertResult.getErrors()) 
                        errors.add(
                            String.format(
                                '[{1}]: {2} ({3}). ', 
                                new List<String>{
                                    String.join(error.getFields(), ', '), 
                                    error.getMessage(), 
                                    String.valueOf(error.getStatusCode())
                                }
                            )
                        ); 
                    throw new leadAutoConvertException('Error while converting Lead: ' + String.join(errors, '; '));
                } else if (accountLookupField != null || contactLookupField != null || opportunityLookupField != null) {
                    if (accountLookupField != null) leadsMap.get(leadConvertResult.getLeadId()).put(accountLookupField, leadConvertResult.getAccountId()); 
                    if (contactLookupField != null) leadsMap.get(leadConvertResult.getLeadId()).put(contactLookupField, leadConvertResult.getContactId()); 
                    if (opportunityLookupField != null) leadsMap.get(leadConvertResult.getLeadId()).put(opportunityLookupField, leadConvertResult.getOpportunityId()); 
                    result.add(leadsMap.get(leadConvertResult.getLeadId()));
                }
        }
        return result; 
    }
    
    global class leadAutoConvertException extends Exception {}

}