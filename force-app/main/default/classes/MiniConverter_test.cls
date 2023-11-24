@isTest
public class MiniConverter_test {
  static testMethod void test() {
    Contact c = new Contact(LastName = 'Buyer', FirstName = 'Shopify');
    insert c;
    Lead l = new Lead(lastname = 'test', company = 'test', LAC_ID__c = '181');
    insert l;
    system.enqueueJob(new MiniConverter(l.id));
    Map<Id, Lead> leads = new Map<Id, Lead>();
    leads.put(l.Id, l);
    system.enqueueJob(new MiniConverter(leads));
  }

  static testMethod void test2() {
    Account a = new Account(name = 'test');
    insert a;
    HardwareFulfilment__c hwf = new HardwareFulfilment__c(
      InternalIDHW__c = '123',
      Account__c = a.Id,
      SerialNumber__c = '123abc'
    );
    insert hwf;
    Product2 p = new Product2(name = 'test', MINI_Eligible__c = false);
    insert p;
    Subscription__c s = new Subscription__c(
      Account__c = a.Id,
      ZuoraId__c = 'test'
    );
    insert s;
    SubscriptionLineItem__c sli = new SubscriptionLineItem__c(
      Subscription__c = s.Id,
      ZuoraId__c = 'test',
      Product__c = p.Id
    );
    insert sli;
    Lead l = new Lead(
      lastname = 'test',
      company = 'test',
      serial_number__c = '123abc'
    );
    insert l;
    Map<Id, Lead> leads = new Map<Id, Lead>();
    leads.put(l.Id, l);
    system.enqueueJob(new MiniConverter(leads));
  }

  static testMethod void Test3() {
    insert new Lead(lastname = 'test', company = 'test', lac_id__c = '180');
    system.assertEquals(
      [SELECT id, pending_autoconversion__c FROM lead LIMIT 1]
      .pending_autoconversion__c,
      true
    );
  }
}