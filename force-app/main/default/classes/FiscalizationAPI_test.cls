@isTest public class FiscalizationAPI_test {

    static TestMethod void test() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fiscalize';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"venueId":"123"}');
        RestContext.request = req;
        RestContext.response = res;
        FiscalizationAPI.RevokeTSE();
        FiscalizationAPI.WizardComplete();
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname = 'test', accountId = a.Id);
        insert c;
        insert new MyObVenue__c(contact__c = c.Id, myorderbirdid__c = '123');
        FiscalizationAPI.WizardComplete();
    }
}