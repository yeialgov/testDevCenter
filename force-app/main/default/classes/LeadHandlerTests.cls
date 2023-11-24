/*************************************************************************
 * Author:           Richard Abendroth
 * Author-Email:     development@incubes.com
 * Author-Website:   www.incubes.com
 *
 * Name:             LeadHandlerTests
 * Type:             Test class
 *
 * Description:      - Test class for the Lead SObject.
 *                   - Will test the following classes
 *                       - LeadHandler
 *************************************************************************/
@isTest
public class LeadHandlerTests {
  /*
    @isTest
    public static void TestLeadTriggerHandler() { 
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];  
        Lead lead1 = new Lead(
            LastName = 'Test Lead', 
            Company = 'Test Company', 
            Status = convertStatus.MasterLabel, 
            Phone = '+1234567890'
        ); 
        insert lead1; 
        lead1.put(LeadHandler.autoConvertField, LeadHandler.autoConvertFieldConvertWithOpportunity); 
        update lead1;  
        System.AssertEquals(true, [SELECT isConverted FROM Lead WHERE Id = :lead1.Id LIMIT 1].isConverted); 
    }
    */
  @TestSetup
  static void makeData() {
    Account a = new Account(name = 'Shopify', target_product__c = 'MINI');
    insert a;
    contact c = new Contact(
      FirstName = 'Shopify',
      lastname = 'Buyer',
      AccountId = a.id
    );
    insert c;
  }

  @isTest
  static void should_rewrite_wrong_formated_phonenumbers() {
    Lead lead = new Lead(
      LastName = '_Burger_',
      Company = '_Comp_',
      Phone = '+49 175 2955188',
      MobilePhone = '+49 175 2955388'
    );
    insert lead;
    lead = [SELECT Phone, MobilePhone FROM Lead WHERE Name = '_Burger_'];
    System.assertEquals('+491752955188', lead.Phone);
    System.assertEquals('+491752955388', lead.MobilePhone);

    lead.Phone = '+49 175 2955188';
    lead.MobilePhone = '+49 175 2955388';
    update lead;
    lead = [SELECT Phone, MobilePhone FROM Lead WHERE Name = '_Burger_'];
    System.assertEquals('+491752955188', lead.Phone);
    System.assertEquals('+491752955388', lead.MobilePhone);
  }

  @isTest
  static void testMiniConverter() {
    List<Lead> miniLeads = new List<Lead>();
    Lead mini180 = new Lead(LastName = 'Birdman', Company = 'Birdjob');
    Lead mini181 = new Lead(
      LastName = 'Birdman1',
      Company = 'Birdjob1',
      email = 'yeisson.gonzalez@orderbird.com'
    );
    Lead mini182 = new Lead(LastName = 'Birdman2', Company = 'Birdjob2');
    miniLeads.add(mini180);
    miniLeads.add(mini181);
    //miniLeads.add(mini182);
    insert miniLeads;
    mini180.lac_id__c = '180';
    mini181.lac_id__c = '181';
    //mini182.lac_id__c = '182';
    update miniLeads;
  }

  @isTest
  static void testLeadSender() {
    Lead mini181 = new Lead(
      LastName = 'Birdman1',
      Company = 'Birdjob1',
      lac_id__c = '181',
      email = 'yeisson.gonzalez@orderbird.com'
    );
    insert mini181;

    String contact_name = [
      SELECT id, Contact__r.Name
      FROM MyObVenue__c
      WHERE lead__c = :mini181.id
      LIMIT 1
    ]
    .Contact__r.Name;
    System.assertEquals('Shopify Buyer', contact_name);
  }
}