@isTest
public class CustomerDataAPITest {
  @TestSetup
  static void Data() {
    Account a = new Account(name = 'TestKonto');
    insert a;
    contact c = new Contact(
      FirstName = 'Jose',
      lastname = 'Canseco',
      AccountId = a.id
    );
    insert c;
    Lead l = new Lead(Lastname = 'TestName', Company = 'VenueName');
    insert l;
    MyObVenue__c v = new MyObVenue__c(Contact__c = c.id);
    insert v;
    CryptAES cs = new CryptAES('AES256');
    String Token = cs.encrypt(v.Id);
    v.Token__c = Token;
    update v;
  }
  
  @isTest
  static void testPutCall() {
    Account a = new Account(Name = 'Shopify');
    insert a;
    Contact c = new Contact(Lastname = 'PalceholderName', AccountId = a.id);
    insert c;
    Lead l = new Lead(LastName = 'TestName', Company = 'MINI Venue');
    insert l;
    MyObVenue__c v = new MyObVenue__c(
      Contact__c = c.id,
      Lead__c = l.id,
      myOrderbirdId__c = '12345'
    );
    insert v;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/customerdata';
    req.httpMethod = 'PUT';
    // req.addHeader('Auth', 'bearer 1234');
    req.requestBody = Blob.valueof(
      '{"CustomerName":"testCompany","email":"dummy@test.com","applicationId":"' +
      v.id +
      '"}'
    );
    RestContext.request = req;
    RestContext.response = res;
    CustomerDataAPI.updateCustomerData();
  }
  @isTest
  static void testPostCall() {
    MyObVenue__c v = [SELECT token__c FROM MyObVenue__c WHERE token__c!=null LIMIT 1];
    String token = v.token__c;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/customerdata';
    req.httpMethod = 'POST';
    req.addHeader('Auth', 'bearer 1234');
    req.requestBody = Blob.valueof('{"name":"test","email":"test@test.com","keyToken":"' +
    token +
    '"}'
    );
    RestContext.request = req;
    RestContext.response = res;
    CustomerDataAPI.registerMyObVenue();
  }

  @isTest
  static void testGetCall() {
    Account a = new Account(Name = 'Shopify');
    insert a;
    Contact c = new Contact(Lastname = 'PalceholderName', AccountId = a.id);
    insert c;
    Lead l = new Lead(LastName = 'TestName', Company = 'MINI Venue');
    insert l;
    MyObVenue__c v = new MyObVenue__c(Contact__c = c.id, Lead__c = l.id);
    insert v;
    CryptAES cs = new CryptAES('AES256');
    String Token = cs.encrypt(v.Id);
    v.Token__c = Token;
    update v;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/customerdata';
    req.addHeader('Auth', 'bearer 1234');
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    CustomerDataAPI.getCustomerInfo(); //test Request without parameters

    req.params.put('keyToken', Token);
    RestContext.request = req;
    CustomerDataAPI.getCustomerInfo(); //test Request with parameters

    String body = res.responseBody.toString();
    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(v.id, m.get('ApplicationId'));

    // change name of test account to test else logic in the ResponseWrapper method of the class
    a.Name = 'NoShopify';
    update a;
    CustomerDataAPI.getCustomerInfo();
  }
}