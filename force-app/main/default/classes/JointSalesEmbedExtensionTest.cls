@isTest
public class JointSalesEmbedExtensionTest {

    static testMethod void test() {
		Account a = new Account(name='test');
        insert a;
		ApexPages.StandardController standardController = new ApexPages.StandardController(a);
		JointSalesEmbedExtension controller = new JointSalesEmbedExtension(standardController);
        Contact c = new Contact(lastname='test', accountid = a.Id);
        insert c;
        a.Caller_Contact__c = c.Id;
        update a;
		ApexPages.StandardController standardController2 = new ApexPages.StandardController(a);
		JointSalesEmbedExtension controller2 = new JointSalesEmbedExtension(standardController2);
        controller2.redirect();
    }
}