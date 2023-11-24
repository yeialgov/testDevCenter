global class MiniConverter implements Queueable, Database.AllowsCallouts {
  global Map<Id, Lead> leads;

  global MiniConverter(Map<Id, Lead> iLeads) {
    leads = iLeads;
  }

  global MiniConverter(Id leadId) {
    Map<Id, Lead> iLeads = new Map<Id, Lead>(
      [
        SELECT Id, Lastname, Serial_Number__c, PrimaryLanguage__c, LAC_ID__c
        FROM Lead
        WHERE id = :leadId
      ]
    );
    leads = iLeads;
  }

  public void execute(QueueableContext context) {
    List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE MasterLabel = 'Qualified MINI'
      LIMIT 1
    ];

    Map<Id, String> SNLeadMap = new Map<Id, String>();
    Map<String, Id> SNAcctMap = new Map<String, Id>();
    Set<Id> HWFAccts = new Set<Id>();
    for (Lead lead : leads.values()) {
      if (lead.Serial_Number__c != null)
        SNLeadMap.put(lead.Id, lead.Serial_Number__c);
    }
    for (HardwareFulfilment__c hwf : [
      SELECT Id, Account__c, Account__r.Related_MINI_Account__c, SerialNumber__c
      FROM HardwareFulfilment__c
      WHERE SerialNumber__c IN :SNLeadMap.values()
    ]) {
      /*HWFAccts.add(hwf.Account__c);
            SNAcctMap.put(
                hwf.SerialNumber__c, 
                hwf.Account__r.Related_MINI_Account__c == null ?
                	hwf.Account__c : hwf.Account__r.Related_MINI_Account__c
            );*/
    }
    Set<Id> NonMINIAccts = new Set<Id>();
    for (AggregateResult ar : [
      SELECT AccountId AcctId
      FROM Quote
      WHERE
        Quote.Status != 'Expired'
        AND Quote.Status != 'Rejected'
        AND AccountId IN :SNAcctMap.values()
        AND Id IN (
          SELECT QuoteId
          FROM QuoteLineItem
          WHERE Product2.MINI_Eligible__c = FALSE
        )
      GROUP BY AccountId
    ]) {
      NonMINIAccts.add((Id) ar.get('AcctId'));
    }
    for (AggregateResult ar : [
      SELECT Account__c AcctId
      FROM Subscription__c
      WHERE
        Account__c IN :SNAcctMap.values()
        AND Id IN (
          SELECT Subscription__c
          FROM SubscriptionLineItem__c
          WHERE Product__r.MINI_Eligible__c = FALSE
        )
      GROUP BY Account__c
    ]) {
      NonMINIAccts.add((Id) ar.get('AcctId'));
    }

    Id MINIownerId = Test.isRunningTest()
      ? UserInfo.getUserId()
      : [SELECT id FROM User WHERE alias = 'dfall' LIMIT 1].id;

    for (Lead lead : leads.values()) {
      Id AcctId = SNAcctMap.get(lead.Serial_Number__c);
      Database.LeadConvert leadConvert = new Database.LeadConvert();
      leadConvert.setLeadId(lead.Id);
      leadConvert.setAccountId(NonMINIAccts.contains(AcctId) ? null : AcctId);
      leadConvert.setConvertedStatus(convertStatus.MasterLabel);
      leadConvert.setDoNotCreateOpportunity(false);
      leadConvert.setOwnerId(MINIownerId);
      leadConverts.add(leadConvert);
    }
    system.debug(json.serialize(leadConverts));
    Database.LeadConvertResult[] leadConvertResults = Database.convertLead(
      leadConverts,
      false
    );
    system.debug(json.serialize(leadConvertResults));

    Map<Id, Id> NewAcctMap = new Map<Id, Id>();
    Map<Id, MyObVenue__c> LeadIdMapVenue = new Map<Id, MyObVenue__c>();
    List<MyObVenue__c> updateVenues = new List<MyObVenue__c>();
    for (MyObVenue__c v : [
      SELECT id, lead__c, contact__c
      FROM MyObVenue__c
      WHERE lead__c IN :leads.keySet()
    ]) {
      LeadIdMapVenue.put(v.lead__c, v);
    }

    for (Database.LeadConvertResult lcr : leadConvertResults) {
      NewAcctMap.put(lcr.accountid, lcr.leadid);
      String lang = leads.get(lcr.leadid).PrimaryLanguage__c;
      if (
        lcr.success && leads.get(lcr.leadid).LAC_ID__c == '180' // sending registration emails only to this leads
      ) {
        AccountLightningController.sendMyObRegistrationEmail(
          lcr.contactId,
          lang == 'English' || lang == 'French' ? lang : 'German',
          'supportmini@orderbird.com'
        );
      } else if (lcr.success && leads.get(lcr.leadid).LAC_ID__c == '181') {
        MyObVenue__c v = LeadIdMapVenue.get(lcr.leadid);
        v.contact__c = lcr.contactid;
        updateVenues.add(v);
      }
    }
    update updateVenues;

    Map<String, Id> ChildMap = new Map<String, Id>();
    for (Account a : [
      SELECT Id
      FROM Account
      WHERE Id IN :NewAcctMap.keySet()
    ]) {
      if (
        SNAcctMap.keySet()
          .contains(leads.get(NewAcctMap.get(a.Id)).Serial_Number__c) &&
        !HWFAccts.contains(a.Id)
      ) {
        ChildMap.put(leads.get(NewAcctMap.get(a.Id)).Serial_Number__c, a.Id);
      }
    }
    List<Account> updateAccounts = new List<Account>();
    for (HardwareFulfilment__c hwf : [
      SELECT Id, Account__c, SerialNumber__c
      FROM HardwareFulfilment__c
      WHERE SerialNumber__c IN :ChildMap.keySet() AND SerialNumber__c != NULL
    ]) {
      updateAccounts.add(
        new Account(
          Id = hwf.Account__c,
          Related_MINI_Account__c = ChildMap.get(hwf.SerialNumber__c)
        )
      );
      updateAccounts.add(
        new Account(
          Id = ChildMap.get(hwf.SerialNumber__c),
          Related_PRO_Account__c = hwf.Account__c,
          Target_Product__c = 'MINI'
        )
      );
    }
    update updateAccounts;
  }
}