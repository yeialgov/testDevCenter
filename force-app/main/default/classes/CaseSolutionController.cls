public class CaseSolutionController {
    
    @AuraEnabled
    public static String getCaseSolutions(String CaseId) {
        return json.serialize([SELECT Id, CaseSolution__r.Name FROM CaseSolutionJunction__c WHERE Case__c = :CaseId]);
    }
    
    @AuraEnabled
    public static void newCaseSolution(String CaseId, String CaseSolutionId, Boolean UpdateSubject) {
        insert new CaseSolutionJunction__c(Case__c = CaseId, CaseSolution__c = CaseSolutionId);
        if (UpdateSubject) {
            Case c = [SELECT Id, Contact.PrimaryLanguage__c, Account.PrimaryLanguage__c, Subject FROM Case WHERE Id = :CaseId LIMIT 1];
            CaseSolution__c cs = [SELECT Id, Name, NameDE__c, NameFR__c FROM CaseSolution__c WHERE Id = :CaseSolutionId LIMIT 1];
            String Subject = cs.NameDE__c;
            if (
                c.Contact.PrimaryLanguage__c == 'English' || (
                    c.Contact.PrimaryLanguage__c == null 
                    && c.Account.PrimaryLanguage__c == 'English'
                )
            ) {
                Subject = cs.Name;
            }
            if (
                c.Contact.PrimaryLanguage__c == 'French' || (
                    c.Contact.PrimaryLanguage__c == null 
                    && c.Account.PrimaryLanguage__c == 'French'
                )
            ) {
                Subject = cs.NameFR__c;
            }
            c.Subject = Subject;
            update c;
        }
    }
    
    @AuraEnabled
    public static void delCaseSolution(String CaseId, String CaseSolutionIds) {
        List<String> CSIds = (List<String>)json.deserialize(CaseSolutionIds, List<String>.class);
        delete [SELECT Id FROM CaseSolutionJunction__c WHERE Case__c = :CaseId AND CaseSolution__c NOT IN :CSIds];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';
        
        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm IN ALL FIELDS RETURNING
            CaseSolutionTranslation__c (Name, Language__c, CaseSolution__c, CaseSolution__r.Name, CaseSolution__r.Description__c WHERE CaseSolution__c NOT IN :selectedIds)
            LIMIT 20
        ];
        
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        String solnIcon = 'custom:custom94';
        CaseSolutionTranslation__c [] CSTs = ((List<CaseSolutionTranslation__c>) searchResults[0]);
        for (CaseSolutionTranslation__c CST : CSTs) {
            if (CST.Language__c == 'EN') results.add(new LookupSearchResult(CST.CaseSolution__c, 'CaseSolutionTranslation__c', solnIcon, '🇬🇧 ' + CST.Name, CST.CaseSolution__r.Description__c, CST.CaseSolution__r.Name));
            if (CST.Language__c == 'DE') results.add(new LookupSearchResult(CST.CaseSolution__c, 'CaseSolutionTranslation__c', solnIcon, '🇩🇪 ' + CST.Name, CST.CaseSolution__r.Description__c, CST.CaseSolution__r.Name));
            if (CST.Language__c == 'FR') results.add(new LookupSearchResult(CST.CaseSolution__c, 'CaseSolutionTranslation__c', solnIcon, '🇫🇷 ' + CST.Name, CST.CaseSolution__r.Description__c, CST.CaseSolution__r.Name));
        }
        return results;
    }
}