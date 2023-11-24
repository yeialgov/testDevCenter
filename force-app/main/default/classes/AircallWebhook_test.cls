@isTest public class AircallWebhook_test {

    static TestMethod void test() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('{"event":"x","token":"y","data":{"id":"z","number":{"id":"123","open":true}}}');
        RestContext.request = req;
        RestContext.response = res;
        insert new Aircall_Forwarding_Rule__c(Transfer_From_NumberId__c = 123, After_Hours__c = true);
        insert new Aircall_Forwarding_Rule__c(Transfer_From_NumberId__c = 123, After_Hours__c = false);
        AircallWebhook.call_created();
    }
}