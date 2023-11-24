trigger SubscriptionLineItemTrigger on SubscriptionLineItem__c (after delete, after insert, after update, before delete, before insert, before update) {
	if(TriggerUtil.executeTrigger('SubscriptionLineItem__c')) {
   		TriggerFactory.createHandler(SubscriptionLineItem__c.sObjectType);
	}
}