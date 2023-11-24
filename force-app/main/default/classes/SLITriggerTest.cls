@isTest public class SLITriggerTest {
    static TestMethod void Test1() {
        Account a = new Account(name='test');
        insert a;
        Subscription__c s1 = new Subscription__c(Account__c = a.Id, Status__c='Active', ZuoraId__c='s1');
        Subscription__c s2 = new Subscription__c(Account__c = a.Id, Status__c='Expired', ZuoraId__c='s2');
        insert s1;
        insert s2;
        Product2 p1 = new Product2(name='VAT 16%',ZuoraId__c='test1');
        insert p1;    
        SubscriptionLineItem__c sl1 = new SubscriptionLineItem__c(Subscription__c = s1.Id, ZuoraId__c='sl1');
        SubscriptionLineItem__c sl2 = new SubscriptionLineItem__c(Subscription__c = s2.Id, ZuoraId__c='sl2');
        SubscriptionLineItem__c sl3 = new SubscriptionLineItem__c(Subscription__c = s2.Id, ZuoraId__c='sl3', product__c=p1.id);
		insert sl1;
		insert sl2;
        insert sl3;
        s1.Status__c = 'Expired';
        s2.Status__c = 'Active';
        update s1;
        update s2;
        }
}