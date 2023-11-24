/*************************************************************************
 * Author:           Richard Abendroth
 * Author-Email:     development@incubes.com
 * Author-Website:   www.incubes.com
 *
 * Name:             LeadHandler
 * Type:             TriggerHandler
 *
 * Description:      - Triggerhandler for Lead sObject
 *                   - See http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 *                   for more details
 *
 * Changes:          2016-11-07: Created by Richard Abendroth
 *					2017-11-13: Modified by Bart Collins
 *						to add LeadTimeCalculator
 *					2017-11-21: Modified by Bart Collins
 *						to add ContactAutoPopulator
 *************************************************************************/
public without sharing class LeadHandler implements ITriggerHandler {
  /*
   * Use this lists for dml operations
   */
  private List<SObject> itemsToInsert = new List<SObject>();
  private List<SObject> itemsToUpdate = new List<SObject>();
  private List<SObject> itemsToDelete = new List<SObject>();

  private RegionManager regionManager;
  private CryptAES crypt;
  //private LeadTimeCalculator leadTimeCalculator;
  private ContactAutoPopulator contactPopulate;
  private Map<Id, Lead> MiniLeads = new Map<Id, Lead>();

  // Lead Auto-Conversion (deactivated 2017-07-17 Issue: SAL-1070)
  /*
    @TestVisible private static Schema.sObjectField autoConvertField = Schema.Lead.AutoConvert__c; 
    @TestVisible private static Object autoConvertFieldConvertWithOpportunity = 'WITH'; 
    @TestVisible private static Object autoConvertFieldConvertWithoutOpportunity = 'WITHOUT'; 
    Set<Id> setDoNotCreateOpportunities = new Set<Id>(); 
    private List<Lead> leadsToBeConverted = new List<Lead>(); 
    */

  /**
   * bulkBefore
   *
   * This method is called prior to execution of a BEFORE trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
  public void bulkBefore() {
    this.regionManager = new RegionManager('Lead');
    //this.leadTimeCalculator = new LeadTimeCalculator();
    if (Trigger.IsUpdate && Trigger.IsBefore)
      this.contactPopulate = new ContactAutoPopulator(Trigger.new);
    new LeadAssignContact(Trigger.new).assign();
    this.crypt = new CryptAES('AES256');
  }

  /**
   * bulkAfter
   *
   * This method is called prior to execution of an AFTER trigger. Use this to cache
   * any data required into maps prior execution of the trigger.
   */
  public void bulkAfter() {
  }

  /**
   * beforeInsert
   *
   * This method is called iteratively for each record to be inserted during a BEFORE
   * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
   */
  public void beforeInsert(SObject so) {
    PhoneNumberCleansing.rewritePhoneNumber(so, 'Phone');
    PhoneNumberCleansing.rewritePhoneNumber(so, 'MobilePhone');
    this.regionManager.setRegionValues(so);
    if (so.get('Email') != null)
      so.put('Token__c', crypt.encrypt((String) so.get('Email')));
  }

  /**
   * beforeUpdate
   *
   * This method is called iteratively for each record to be updated during a BEFORE
   * trigger.
   */
  public void beforeUpdate(SObject oldSo, SObject so) {
    PhoneNumberCleansing.rewritePhoneNumber(so, 'Phone');
    PhoneNumberCleansing.rewritePhoneNumber(so, 'MobilePhone');
    this.regionManager.updateRegionValues(so, oldSo);
    //this.leadTimeCalculator.updateLeadTimeValues(so, oldSo);
    this.contactPopulate.updateContactLookups(so, oldSo);
    if (
      (String) so.get('LAC_ID__c') == '180' &&
      !(Boolean) so.get('Pending_Autoconversion__c')
    ) {
      MiniLeads.put((Id) so.get('Id'), (Lead) so);
      so.put('Pending_Autoconversion__c', true);
    }
  }

  /**
   * beforeDelete
   *
   * This method is called iteratively for each record to be deleted during a BEFORE
   * trigger.
   */
  public void beforeDelete(SObject so) {
    if ((String) so.get('MetroOpportunityId__c') != null)
      so.addError('Cannot delete Lead with Metro Opportunity Id.');
  }

  /**
   * afterInsert
   *
   * This method is called iteratively for each record inserted during an AFTER
   * trigger. Always put field validation in the 'After' methods in case another trigger
   * has modified any values. The record is 'read only' by this point.
   */
  public void afterInsert(SObject so) {
    if ((string) so.get('LAC_ID__c') == '181') {
      MiniOnboarding.sendMyObRegistrationEmailLead((String) so.get('Id'));
    }
    /*
        if ((so.get(autoConvertField) == autoConvertFieldConvertWithOpportunity || so.get(autoConvertField) == autoConvertFieldConvertWithoutOpportunity) && 
            (Boolean)so.get(Schema.Lead.isConverted) == false) {
            leadsToBeConverted.add((Lead)so); 
            if (so.get(autoConvertField) == autoConvertFieldConvertWithoutOpportunity) 
                setDoNotCreateOpportunities.add(((Lead)so).Id); 
        }
        */
  }

  /**
   * afterUpdate
   *
   * This method is called iteratively for each record updated during an AFTER
   * trigger.
   */
  public void afterUpdate(SObject oldSo, SObject so) {
    /*
        if (oldSo.get(autoConvertField) != so.get(autoConvertField) && 
            (so.get(autoConvertField) == autoConvertFieldConvertWithOpportunity || so.get(autoConvertField) == autoConvertFieldConvertWithoutOpportunity) && 
            true ) {//(Boolean)so.get(Schema.Lead.isConverted) == false) { 
            leadsToBeConverted.add((Lead)so); 
            if (so.get(autoConvertField) == autoConvertFieldConvertWithoutOpportunity) 
                setDoNotCreateOpportunities.add(((Lead)so).Id); 
        }
        */
  }

  /**
   * afterDelete
   *
   * This method is called iteratively for each record deleted during an AFTER
   * trigger.
   */
  public void afterDelete(SObject so) {
  }

  /**
   * andFinally
   *
   * This method is called once all records have been processed by the trigger. Use this
   * method to accomplish any final operations such as creation or updates of other records.
   */
  public void andFinally() {
    // System.Debug(leadsToBeConverted);
    // System.Debug(setDoNotCreateOpportunities);
    // if (Trigger.isAfter && leadsToBeConverted.size() > 0)
    //    LeadAutoConvert.convert(leadsToBeConverted, setDoNotCreateOpportunities);
    //update LeadAutoConvert.convert(leadsToBeConverted, setDoNotCreateOpportunities, Schema.Lead.ConvertedToAccountId, null, Schema.Lead.ConvertedToOpportunityId);
    //insert itemsToInsert;
    //update itemsToUpdate;
    //delete itemsToDelete;

    if (Trigger.isBefore && Trigger.isUpdate)
      contactPopulate.updateAccounts();
    if (MiniLeads.keySet().size() > 0)
      system.enqueueJob(new MiniConverter(MiniLeads));
  }
}