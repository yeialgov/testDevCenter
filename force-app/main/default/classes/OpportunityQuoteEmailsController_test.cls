@isTest public class OpportunityQuoteEmailsController_test {

    static TestMethod void test() {
        String s = JSON.serialize(OpportunityQuoteEmailsController.getEmails(null));
    }
}