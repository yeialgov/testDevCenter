public class MiniOnboarding {
  public static void sendMyObRegistrationEmailLead(String LeadId) {
    Id ContactId = [SELECT id FROM Contact WHERE Name = 'Shopify Buyer' LIMIT 1]
    .Id;
    MyObVenue__c v = new MyObVenue__c(Contact__c = ContactId, Lead__c = LeadId);
    insert v;
    CryptAES cs = new CryptAES('AES256');
    String Token = cs.encrypt(v.Id);
    v.Token__c = Token;
    update v;

    try {
      EmailAutomater.AutomatedTemplateEmail(
        new List<EmailAutomater.EmailAutomationRequest>{
          new EmailAutomater.EmailAutomationRequest(
            v.Lead__c,
            v.Id,
            'MyOrderbirdRegistration:German', // Known Issue: It only allows the use of German Template
            'supportmini@orderbird.com'
          )
        }
      );
    } catch (Exception e) {
      System.debug('Exception type caught: ' + e.getTypeName());
    }
  }

  public static void updateLeadInfo(MyObVenue__c v, MyOBWrapper payload) {
    //update Lead fields
    v.lead__r.Company = payload.CustomerName != null
      ? payload.CustomerName
      : v.lead__r.Company;
    v.lead__r.city = payload.City != null ? payload.City : v.lead__r.city;
    v.lead__r.CountryCode = payload.CountryCode != null
      ? payload.CountryCode
      : v.lead__r.CountryCode;
    v.lead__r.email = payload.Email != null ? payload.Email : v.lead__r.email;

    update v.lead__r;
  }

  public static void updateAccConInfo(MyObVenue__c v, MyOBWrapper payload) {
    // Update Account and Contact Info related to the Venue object
    v.account__r.Name = payload.CustomerName != null
      ? payload.CustomerName
      : v.account__r.Name;
    v.account__r.VenueStreet__c = payload.Address != null
      ? payload.Address
      : v.account__r.VenueStreet__c;
    v.account__r.VenuePostalCode__c	 = payload.PostalCode != null
      ? payload.PostalCode
      : v.account__r.VenuePostalCode__c	;
    v.account__r.VenueCity__c = payload.City != null
      ? payload.City
      : v.account__r.VenueCity__c;
    v.account__r.VenueCountry__c = payload.Country != null
      ? payload.Country
      : v.account__r.VenueCountry__c;
    v.contact__r.email = payload.Email != null
      ? payload.Email
      : v.contact__r.email;
    v.contact__r.firstName = payload.FirstName != null
      ? payload.FirstName
      : v.contact__r.firstName;
    v.contact__r.lastName = payload.LastName != null
      ? payload.LastName
      : v.contact__r.lastName;
    v.contact__r.phone = payload.Phone != null
      ? payload.Phone
      : v.contact__r.phone;

    // Assign value BILL-SHIP to display the Venue Address in the AddressBuilderNew_Account.cmp in the account record
    if (v.account__r.VenueStreet__c != v.account__r.BillingStreet || v.account__r.VenueStreet__c != v.account__r.ShippingStreet){
      if(v.account__r.ShippingStreet != v.account__r.BillingStreet){
        v.account__r.AddressSyncType__c = null;
      }else{
        v.account__r.AddressSyncType__c = 'BILL-SHIP';
      }
    }

    update v.account__r;
    update v.contact__r;
  }
}