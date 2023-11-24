public class AccountLightningController {
  @AuraEnabled
  public static String matchContacts(String MyObVenueId) {
    return JSON.serialize(new ContactMatchWrapper(MyObVenueId));
  }

  @AuraEnabled
  public static void ReparentMyObVenue(String MyObVenueId, String ContactId) {
    List<Account> DeleteAccounts = new List<Account>();
    MyObVenue__c v = [
      SELECT Id, Contact__c, Contact__r.AccountId, Contact__r.Name
      FROM MyObVenue__c
      WHERE Id = :MyObVenueId
      LIMIT 1
    ];
    if (v.Contact__r.Name == 'MyOrderbird Registrant')
      DeleteAccounts.add(new Account(Id = v.Contact__r.AccountId));
    v.Contact__c = ContactId;
    update v;
    delete DeleteAccounts;
  }

  @AuraEnabled
  public static List<MyObVenue__c> getMyObVenues(String AccountId) {
    return [
      SELECT Id, Contact__c, MyOrderbirdId__c, Uncertainty__c
      FROM MyObVenue__c
      WHERE MyOrderbirdId__c != NULL AND Contact__r.AccountId = :AccountId
      ORDER BY AssignmentSort__c DESC, MyOrderbirdId__c
    ];
  }

  @AuraEnabled
  public static String getObWarning(String AccountId) {
    return JSON.serialize(new ObWarningWrapper(AccountId));
  }

  @AuraEnabled
  public static void confirmObVenue(String MyObVenueId) {
    MyObVenue__c v = [
      SELECT Id, Uncertainty__c
      FROM MyObVenue__c
      WHERE Id = :MyObVenueId
      LIMIT 1
    ];
    v.Uncertainty__c = null;
    update v;
  }

  @AuraEnabled
  public static void sendMyObRegistrationEmail(
    String ContactId,
    String Language
  ) {
    AccountLightningController.sendMyObRegistrationEmail(
      ContactId,
      Language,
      null
    );
  }

  @AuraEnabled
  public static void sendMyObRegistrationEmail(
    String ContactId,
    String Language,
    String EmailAddress
  ) {
    MyObVenue__c v = new MyObVenue__c(Contact__c = ContactId);
    insert v;
    CryptAES cs = new CryptAES('AES256');
    String Token = cs.encrypt(v.Id);
    v.Token__c = Token;
    update v;
    if (!Test.isRunningTest())
      EmailAutomater.AutomatedTemplateEmail(
        new List<EmailAutomater.EmailAutomationRequest>{
          new EmailAutomater.EmailAutomationRequest(
            v.Contact__c,
            v.Id,
            'MyOrderbirdRegistration:' + Language,
            EmailAddress
          )
        }
      );
  }

  @AuraEnabled
  public static String getVATVerify(String VATNumber) {
    return JSON.serialize(VIES.checkVAT(VATNumber));
  }

  @AuraEnabled
  public static Boolean saveVAT(
    String AccountId,
    Boolean UpdateAddress,
    String VIES_json
  ) {
    system.debug(AccountId);
    system.debug(VIES_json);
    system.debug(UpdateAddress);
    VIES.VATCheck VIES = (VIES.VATCheck) JSON.deserialize(
      VIES_json,
      VIES.VATCheck.class
    );
    Account a = [
      SELECT
        Id,
        VATNumber__c,
        LegalCompanyName__c,
        BillingStreet,
        BillingCity,
        BillingPostalCode,
        BillingCountryCode
      FROM Account
      WHERE Id = :AccountId
      LIMIT 1
    ];
    try {
      a.VATNumber__c = VIES.vatID;
      a.LegalCompanyName__c = VIES.name;
      update a;
      if (UpdateAddress) {
        AddressWrapper addr = new AddressWrapper(VIES.address, VIES.vatID);
        a.BillingStreet = addr.Street;
        a.BillingCity = addr.City;
        a.BillingPostalCode = addr.PostalCode;
        a.BillingCountryCode = addr.CountryCode;
        update a;
      }
    } catch (exception e) {
      system.debug(e.getMessage());
      system.debug(String.valueOf(e.getLineNumber()));
      return false;
    }
    return true;
  }

  @AuraEnabled
  public static void updateAddressBuilder(
    String AccountId,
    String AddressType,
    String AddressBuilder
  ) {
    Account a = [
      SELECT
        Id,
        AddressBuilder__c,
        AddressBuilder_Shipping__c,
        AddressBuilder_Venue__c
      FROM Account
      WHERE Id = :AccountId
      LIMIT 1
    ];
    String BuilderField = 'AddressBuilder_' + AddressType + '__c';
    a.put(BuilderField.replace('_Billing', ''), AddressBuilder);
    update a;
  }

  @AuraEnabled
  public static String getAddressBuilder(String AccountId, String AddressType) {
    Account a = [
      SELECT
        Id,
        AddressBuilder__c,
        AddressBuilder_Shipping__c,
        AddressBuilder_Venue__c
      FROM Account
      WHERE Id = :AccountId
      LIMIT 1
    ];
    String BuilderField = 'AddressBuilder_' + AddressType + '__c';
    return (String) a.get(BuilderField.replace('_Billing', ''));
  }

  @AuraEnabled
  public static String getAccountContacts(String AccountId) {
    return json.serialize(
      [
        SELECT Id, Name, Email, Phone, MobilePhone
        FROM Contact
        WHERE AccountId = :AccountId
        ORDER BY
          Primary_Contact__c DESC,
          Zuora_SoldTo_Contact__c DESC,
          Zuora_BillTo_Contact__c DESC,
          VenueContact__c DESC,
          LastName,
          FirstName
      ]
    );
  }

  @AuraEnabled
  public static String getRelatedDocuments(String AccountId) {
    return JSON.serialize(new RelDocWrapper(AccountId));
  }

  @AuraEnabled
  public static void replaceBamboraRegId(String VenueId) {
    system.enqueueJob(new BamboraOnboard(VenueId));
  }

  public class ContactMatchWrapper {
    public Contact TargetContact { get; set; }
    public List<Contact> MatchContacts { get; set; }
    public ContactMatchWrapper(String MyObVenueId) {
      TargetContact = [
        SELECT
          Id,
          Email,
          Account.BillingCity,
          Account.BillingCountry,
          Account.Name,
          Account.MyOrderbirdEmail__c
        FROM Contact
        WHERE
          Id IN (SELECT Contact__c FROM MyObVenue__c WHERE Id = :MyObVenueId)
        LIMIT 1
      ];
      MatchContacts = [
        SELECT
          Id,
          Name,
          Email,
          Account.BillingCity,
          Account.BillingCountry,
          Account.Name,
          Account.Account_Status__c,
          Primary_Contact__c,
          Account.CustomerId__c
        FROM Contact
        WHERE
          Id != :TargetContact.Id
          AND (Email = :TargetContact.Email
          OR (Primary_Contact__c = TRUE
          AND Account.Name = :TargetContact.Account.Name)
          OR (Primary_Contact__c = TRUE
          AND Account.MyOrderbirdEmail__c = :TargetContact.Email))
        LIMIT 20
      ];
    }
  }

  public class ObWarningWrapper {
    public Boolean NoWarning { get; set; }
    public Boolean SentEmail { get; set; }
    public String PrimaryContactId { get; set; }
    public String PrimaryContactEmail { get; set; }
    public ObWarningWrapper(String AccountId) {
      NoWarning =
        [
          SELECT Id
          FROM MyObVenue__c
          WHERE MyOrderbirdId__c != NULL AND Contact__r.AccountId = :AccountId
        ]
        .size() > 0;
      if (!NoWarning) {
        SentEmail =
          [SELECT Id FROM MyObVenue__c WHERE Contact__r.AccountId = :AccountId]
          .size() > 0;
        Account a = [
          SELECT Id, Primary_Contact__c, Primary_Contact__r.Email
          FROM Account
          WHERE Id = :AccountId
          LIMIT 1
        ];
        PrimaryContactId = a.Primary_Contact__c;
        PrimaryContactEmail = a.Primary_Contact__r.Email;
      }
    }
  }

  public class RelDocWrapper {
    public List<RelatedDoc> InvoiceDocs { get; set; }
    public List<RelatedDoc> QuoteDocs { get; set; }
    public RelDocWrapper(String AccountId) {
      InvoiceDocs = new List<RelatedDoc>();
      QuoteDocs = new List<RelatedDoc>();
      Map<Id, Invoice__c> InvoiceMap = new Map<Id, Invoice__c>(
        [SELECT Id, Name FROM Invoice__c WHERE Account__c = :AccountId]
      );
      Map<Id, EmailMessage> EmailMessageMap = new Map<Id, EmailMessage>(
        [
          SELECT Id, RelatedToId
          FROM EmailMessage
          WHERE RelatedToId IN :InvoiceMap.keySet()
        ]
      );
      Set<Id> EmailMessageIdSet = EmailMessageMap.keySet();
      if (EmailMessageIdSet.size() > 0) {
        for (ContentDocumentLink CDL : [
          SELECT
            Id,
            LinkedEntityId,
            ContentDocumentId,
            ContentDocument.Title,
            ContentDocument.CreatedDate
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :EmailMessageIdSet
          ORDER BY ContentDocument.CreatedDate DESC
        ]) {
          InvoiceDocs.add(
            new RelatedDoc(
              CDL.ContentDocumentId,
              CDL.ContentDocument.Title,
              EmailMessageMap.get(CDL.LinkedEntityId).RelatedToId,
              InvoiceMap.get(
                  EmailMessageMap.get(CDL.LinkedEntityId).RelatedToId
                )
                .Name,
              CDL.ContentDocument.CreatedDate
            )
          );
        }
      }
      Map<Id, Quote> QuoteMap = new Map<Id, Quote>(
        [SELECT Id, QuoteNumber FROM Quote WHERE AccountId = :AccountId]
      );
      Set<Id> QuoteIdSet = QuoteMap.keySet();
      if (QuoteIdSet.size() > 0) {
        for (ContentDocumentLink CDL : [
          SELECT
            Id,
            LinkedEntityId,
            ContentDocumentId,
            ContentDocument.Title,
            ContentDocument.CreatedDate
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :QuoteIdSet
          ORDER BY ContentDocument.CreatedDate DESC
        ]) {
          QuoteDocs.add(
            new RelatedDoc(
              CDL.ContentDocumentId,
              CDL.ContentDocument.Title,
              CDL.LinkedEntityId,
              QuoteMap.get(CDL.LinkedEntityId).QuoteNumber,
              CDL.ContentDocument.CreatedDate
            )
          );
        }
      }
    }
  }

  public class RelatedDoc {
    public String Id { get; set; }
    public String Name { get; set; }
    public String RelatedId { get; set; }
    public String RelatedName { get; set; }
    public DateTime Stamp { get; set; }
    public RelatedDoc(
      String iId,
      String iName,
      String iRelatedId,
      String iRelatedName,
      DateTime iStamp
    ) {
      Id = iId;
      Name = iName;
      RelatedId = iRelatedId;
      RelatedName = iRelatedName;
      Stamp = iStamp;
    }
  }

  public class AddressWrapper {
    public String Street { get; set; }
    public String City { get; set; }
    public String PostalCode { get; set; }
    public String CountryCode { get; set; }
    public AddressWrapper(String rawAddress, String VATId) {
      CountryCode = VATId.substring(0, 2);
      system.debug(VATId + '|' + CountryCode);
      List<String> AddressParts = rawAddress.split('[\n]');
      Street = AddressParts[0];
      for (Integer x = 1; AddressParts.size() > x + 1; x++) {
        Street += '\n' + AddressParts[x];
      }
      List<String> LastLineParts = AddressParts[AddressParts.size() - 1]
        .split(' ', 2);
      City = LastLineParts[1];
      PostalCode = LastLineParts[0];
      if (PostalCode.contains('-'))
        PostalCode = PostalCode.split('-')[1];
    }
  }
}