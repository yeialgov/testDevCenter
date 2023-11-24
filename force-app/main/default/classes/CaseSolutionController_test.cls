@isTest public class CaseSolutionController_test {

    static TestMethod void test() {
        Case c = new Case();
        insert c;
        CaseSolution__c cs = new CaseSolution__c(name='test case solution',namefr__c='lcs',creator__c=c.Id);
        insert cs;
        CaseSolutionController.newCaseSolution(c.Id, cs.Id, true);
        system.debug(json.serialize(CaseSolutionController.search('test', new List<String>{})));
        CaseSolutionController.delCaseSolution(c.Id, json.serialize(new List<String>{cs.Id}));
    }
    
    static TestMethod void test2() {
        LookupSearchResult lsr = new LookupSearchResult(null,null,null,null,null,null);
        Id i = lsr.getId();
        String s = lsr.getEngName();
        s = lsr.getIcon();
        s = lsr.getSObjectType();
        s = lsr.getSubtitle();
        s = lsr.getTitle();
    }
}