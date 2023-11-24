@isTest public class QuoteLeadController_test {

    static TestMethod void test() {
        Send_Template_Folder__c stf = new Send_Template_Folder__c(name='test');
        insert stf;
        SendTemplate__c st = new SendTemplate__c(Subject__c = 'test', Message__c = 'test', folder__c = stf.id, object__c='Lead', adminname__c='QuotePreorder_EN');
        insert st;
        Lead l = new Lead(lastname='test', company='test', email='bart.collins@orderbird.com', lac_id__c = '800');
        insert l;
        QuoteLeadController.GenerateQuoteId(new List<Id>{ l.Id });
    }
}