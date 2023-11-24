@isTest public class JointSalesExtension_Test {
    
    static testmethod void test() {
        Account a = new Account(name='test');
        insert a;
        Account p = new Account(name='test',AccountType__c='partner',partnertype__c='joint sales');
        insert p;
        insert new Joint_Sales__c(customer__c=a.Id,partner__c=p.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        JointSalesExtension jse = new JointSalesExtension(sc);
        PageReference pr = jse.jsSave();
        pr = jse.jsCancel();
    }
}