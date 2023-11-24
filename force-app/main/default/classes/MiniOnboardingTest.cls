@isTest
public class MiniOnboardingTest {
  @TestSetup
  static void makeData() {
    //Data for the POST request
    Account a = new Account(name = 'Shopify', target_product__c = 'MINI');
    insert a;
    contact c = new Contact(
      FirstName = 'Shopify',
      lastname = 'Buyer',
      AccountId = a.id
    );
    insert c;
    
    //Data for the PUT request
    Account a2 = new Account(name = 'Test Konto');
    insert a2;
    contact c2 = new Contact(
      FirstName = 'Test',
      lastname = 'User',
      AccountId = a2.id
    );
    insert c2;
    MyObVenue__c v2 = new MyObVenue__c(Contact__c = c2.id);
    insert v2;
    
        
    Lead l = new Lead(Lastname = 'TestName', Company = 'MINI Venue');
    insert l;
    MyObVenue__c v = new MyObVenue__c(Contact__c = c.id, Lead__c = l.id);
    insert v;
    CryptAES cs = new CryptAES('AES256');
    String Token = cs.encrypt(v.Id);
    v.Token__c = Token;
    update v;
  }

  @isTest
  static void test1() {
    //test the creation of a MyOBvenue record with the right placeholder contact
    //after a MINI Lead with the corresponding lac id is created
    Lead mini181 = new Lead(
      LastName = 'Birdman1',
      Company = 'Birdjob1',
      lac_id__c = '181',
      email = 'test@orderbird.com'
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

  @IsTest
  static void test2() {
    //after the successfull registration process of a MINI customer,
    //system receives a POST call from backend and update the related lead

    MyObVenue__c v = [
      SELECT id, token__c, contact__c
      FROM myobvenue__c
      WHERE contact__r.LastName = 'Buyer'
      LIMIT 1
    ];

    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = 'customerdata/services/apexrest/customerdata';
    req.httpMethod = 'POST';
    req.addHeader('Auth', 'bearer 1234');
    req.requestBody = Blob.valueof(
      '{"venueId":"12345","keyToken":"' +
      v.token__c +
      '","LastName":"Stone"}'
    );
    RestContext.request = req;
    RestContext.response = res;

    CustomerDataAPI.registerMyObVenue();
    Test.stopTest();
  }
    
    @IsTest
  static void test3() {
    // after customer submit onboarding form OR update their business info in MyOrderbird
    // MyOrderbird sends a PUT request that updates some customer data.
    // The lookup relations for Contact and Account of the MyObVenue__c object are updated  

    MyObVenue__c v = [
      SELECT id, token__c, contact__c
      FROM myobvenue__c
      WHERE contact__r.LastName = 'User'
      LIMIT 1
    ];
      
    Contact c_before = [
          SELECT id, FirstName From Contact
          WHERE LastName = 'User'
          LIMIT 1
      ];

    Test.startTest();

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = 'customerdata/services/apexrest/customerdata';
    req.httpMethod = 'PUT';
    // req.addHeader('Auth', 'bearer 1234');
    req.requestBody = Blob.valueof(
      '{"applicationId":"'+v.id+
        '","FirstName":"Rolling","LastName":"Stone"}'
    );
    RestContext.request = req;
    RestContext.response = res;

    CustomerDataAPI.updateCustomerData();
    Test.stopTest();
      
      Contact c_after = [
          SELECT id, FirstName From Contact
          WHERE id = :c_before.id
          LIMIT 1
      ];
      
      System.assertNotEquals(c_after.FirstName, c_before.FirstName);

  }

}