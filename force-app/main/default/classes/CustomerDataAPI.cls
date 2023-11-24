@RestResource(urlMapping='/customerdata')
global class CustomerDataAPI {
@HttpPut
  global static void updateCustomerData() {
    // define Payload
    RestRequest req = System.RestContext.request;
		System.debug(req.requestBody.size());
      System.debug(req.requestBody.toString());
    MyOBWrapper payload = (MyOBWrapper) JSON.deserialize(
      req.requestBody.toString(),
      MyOBWrapper.class
    );
	System.debug(payload);
    // No authentication for the call

    // Find customer
    Id keyId = payload.applicationId;
    MyObVenue__c MyObVenue = QueryVenue(keyId);
    
    try {
      MiniOnboarding.updateAccConInfo(MyObVenue, payload);
    } catch (DmlException e) {
      System.RestContext.response.responseBody = Blob.valueOf(BadSave());
      throw e;
    }

    String CustomerId = MyObVenue.account__r.customeridtext__c;
	
    //send Bambora/Worldline Onboarding email to MINI customers
      if (!Test.isRunningTest()&&
        MyObVenue.BamboraId__c == null &&
        MyObVenue.account__r.Target_Product__c == 'MINI')
        System.enqueueJob(new BamboraOnboard(MyObVenue.Id));
      
    System.RestContext.response.responseBody = Blob.valueOf(
      JSON.serialize(new ResponseWrapper(CustomerId, MyObVenue, keyId))
    );
  }

@HttpPost
  global static void registerMyObVenue() {
    String CustomerId;
    CryptAES cs = new CryptAES('AES256');
    RestRequest req = System.RestContext.request;
    MyOBWrapper payload = (MyOBWrapper) JSON.deserialize(
      req.requestBody.toString(),
      MyOBWrapper.class
    );

    Map<String, Object> reqMap = (Map<String, Object>) JSON.deserializeUntyped(
      req.requestBody.toString()
    );
    system.debug(json.serialize(reqMap));

    //authenticate
    try {
      List<String> AuthHeader = req.headers.get('Auth').split(' ');
      String accessToken;
      if (AuthHeader.size() == 2 && AuthHeader[0] == 'bearer')
        accessToken = AuthHeader[1];
      if (cs.decrypt(accessToken) != 'My.Orderbird')
        System.RestContext.response.responseBody = Blob.valueOf(BadToken());
    } catch (exception e) {
      System.RestContext.response.responseBody = Blob.valueOf(BadToken());
    }

    //find customer
    String keyToken = payload.keyToken;
    String myObId = payload.venueId;
    String keyId = null;
    if (myObId == null)
      System.RestContext.response.responseBody = Blob.valueOf(MissingMyObId());
    /*
    //OUTDATED Process that enabled customers to register without using a Token
    //This must not be possible anymore.

    if (keyToken == null) {
      Contact c = new Contact(
        firstname = 'MyOrderbird',
        lastname = 'Registrant',
        email = (String) reqMap.get('email')
      );
      insert c;
      Account a = new Account(
        name = (String) reqMap.get('name'),
        primary_contact__c = c.id,
        sf_billto_contact__c = c.id,
        sf_soldto_contact__c = c.id,
        Venuecountry__c = (String) reqMap.get('country'),
        Venuecity__c = (String) reqMap.get('city')
      );
      try {
        insert a;
      } catch (exception e) {
        a.VenueCountry__c = null;
        insert a;
      }
      c.AccountId = a.Id;
      update c;
      MyObVenue__c m = new MyObVenue__c(Contact__c = c.Id);
      insert m;
      keyId = m.Id;
    }
    */

    if (keyId == null) {
      keyId = cs.decrypt(keyToken);
    }

    MyObVenue__c MyObVenue = QueryVenue(keyId);
	    
    if (MyObVenue.MyOrderbirdId__c != null) {
      System.RestContext.response.responseBody = Blob.valueOf(BadSave());
    } else {
      MyObVenue.MyOrderbirdId__c = myObId;
      if (MyObVenue.Lead__c != null) {
        CustomerId = null;
        MiniOnboarding.updateLeadInfo(MyObVenue, payload);
        System.enqueueJob(new MiniConverter(MyObVenue.Lead__c));
      } else {
        CustomerId = MyObVenue.account__r.customeridtext__c;
        // MiniOnboarding.updateAccConInfo(MyObVenue, payload);
      	
        //send Bambora/Worldline Onboarding email to PRO customers
        if (!Test.isRunningTest())
        System.enqueueJob(new BamboraOnboard(MyObVenue.Id));
      }
      update MyObVenue;
      

      System.RestContext.response.responseBody = Blob.valueOf(
        JSON.serialize(new ResponseWrapper(CustomerId, MyObVenue, keyId))
      );
    }
  }

  @HttpGet
  global static void getCustomerInfo() {
    CryptAES cs = new CryptAES('AES256');
    RestRequest req = System.RestContext.request;

    //authenticate
    try {
      List<String> AuthHeader = req.headers.get('Auth').split(' ');
      String accessToken;
      if (AuthHeader.size() == 2 && AuthHeader[0] == 'bearer')
        accessToken = AuthHeader[1];
      if (cs.decrypt(accessToken) != 'My.Orderbird')
        System.RestContext.response.responseBody = Blob.valueOf(BadToken());
    } catch (exception e) {
      System.RestContext.response.responseBody = Blob.valueOf(BadToken());
    }

    //find customer
    String keyToken = req.params.get('keyToken');
    if (keyToken == null)
      System.RestContext.response.responseBody = Blob.valueOf(MissingKey());
    else {
      String keyId = cs.decrypt(keyToken);
      MyObVenue__c MyObVenue = QueryVenue(keyId);
      System.debug(MyObVenue);
     
      if (MyObVenue.MyOrderbirdId__c == null) {
        System.RestContext.response.responseBody = Blob.valueOf(
          JSON.serialize(new ResponseWrapper(MyObVenue))
        );
      } else {
        System.RestContext.response.responseBody = Blob.valueOf(BadSave());
      }
    }
  }

  public class ResponseWrapper {
    public String CustomerId { get; set; }
    public String ApplicationId { get; set; }
    public String CustomerName { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Address { get; set; }
    public String PostalCode { get; set; }
    public String City { get; set; }
    public String CountryCode { get; set; }
    public String Phone { get; set; }
    public String Email { get; set; }
    public String VenueId { get; set; }
    public List<String> Products { get; set; }

    public ResponseWrapper(String custId, MyObVenue__c v, String vId) {
      CustomerId = custId;
      ApplicationId = vId;
      VenueId = v.MyOrderbirdId__c;
    }

    public ResponseWrapper(MyObVenue__c v) {
      //condition for all Venues that are connected with Placeholder Account for Shopify Device Buyers
      if (v.Account__r.Name == 'Shopify') {
        CustomerId = null;
        ApplicationId = v.Id != null ? v.id : null;
        CustomerName = v.lead__r.company != null ? v.lead__r.company : null;
        FirstName = v.lead__r.firstName != null ? v.lead__r.firstname : null;
        LastName = v.lead__r.lastName != null ? v.lead__r.lastName : null;
        City = v.lead__r.city != null ? v.lead__r.city : null;
        CountryCode = v.lead__r.CountryCode != null
          ? v.lead__r.countrycode
          : null;
        Email = v.lead__r.Email != null ? v.lead__r.email : null;
        Address = v.lead__r.street != null ? v.lead__r.street : null;
        PostalCode = v.lead__r.postalcode != null ? v.lead__r.postalcode : null;
        Phone = v.lead__r.phone != null ? v.lead__r.phone : null;
        Products = new List<String>{ 'MINI' };
        //condition for all the other Venues
      } else {
        CustomerId = v.Account__r.CustomerIdText__c != null
          ? v.account__r.customeridtext__c
          : null;
        ApplicationId = v.Id;
        CustomerName = v.Account__r.Name != null ? v.account__r.name : null;
        FirstName = v.contact__r.firstName != null
          ? v.contact__r.firstname
          : null;
        LastName = v.contact__r.lastName != null ? v.contact__r.lastname : null;
        City = v.Account__r.Venuecity__c != null
          ? v.account__r.Venuecity__c
          : null;
        CountryCode = v.Account__r.VenueCountryCode__c != null
          ? v.account__r.VenueCountryCode__c
          : null;
        Email = v.Contact__r.Email != null ? v.contact__r.Email : null;
        Address = v.Account__r.VenueStreet__c != null
          ? v.account__r.VenueStreet__c
          : null;
        PostalCode = v.Account__r.VenuePostalCode__c != null
          ? v.account__r.VenuePostalCode__c
          : null;
        Phone = v.Contact__r.phone != null ? v.contact__r.phone : null;
        Products = v.Account__r.Target_Product__c == null
          ? new List<String>{ 'PRO' }
          : v.Account__r.Target_Product__c.replace(' ', '').split(';');
      }
    }
  }

  private static MyObVenue__c QueryVenue(Id venueId) {
    MyObVenue__c Venue;
    try {
      Venue = [
        SELECT
          id,
          myorderbirdid__c,
          BamboraId__c,
          account__c,
          account__r.Name,
          account__r.CustomerIdText__c,
          account__r.Target_Product__c,
          account__r.VenueCity__c,
          account__r.VenueCountry__c,
          account__r.VenueCountryCode__c,
          account__r.Venuepostalcode__c,
          account__r.Venuestreet__c,
          account__r.BillingStreet,
          account__r.ShippingStreet,
          account__r.AddressSyncType__c,
          contact__c,
          contact__r.Email,
          contact__r.FirstName,
          contact__r.lastname,
          contact__r.phone,
          lead__c,
          lead__r.firstName,
          lead__r.lastname,
          lead__r.company,
          lead__r.Email,
          lead__r.street,
          lead__r.city,
          lead__r.postalcode,
          lead__r.countrycode,
          lead__r.phone
        FROM MyObVenue__c
        WHERE Id = :venueId
        LIMIT 1
      ];
    } catch (Exception e) {
      System.RestContext.response.responseBody = Blob.valueOf(NoSuchKey());
      throw e;
    }
    return Venue;
  }

  public static String BadToken() {
    RestContext.response.statusCode = 401;
    return '{"Error":"Could not authenticate. Bad or missing Authentication header."}';
  }

  public static String NoSuchKey() {
    RestContext.response.statusCode = 404;
    return '{"Error":"Key Token not found in Server."}';
  }

  public static String MissingKey() {
    RestContext.response.statusCode = 400;
    return '{"Error":"Key Token not provided."}';
  }

  public static String MissingMyObId() {
    RestContext.response.statusCode = 400;
    return '{"Error":"Venue Id not provided."}';
  }

  public static String BadSave() {
    RestContext.response.statusCode = 500;
    return '{"Error":"Internal Server Error."}';
  }
}