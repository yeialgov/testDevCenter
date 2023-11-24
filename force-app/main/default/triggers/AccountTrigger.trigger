trigger AccountTrigger on Account (after delete, after insert, after update, before delete, before insert, before update)
{
	if(TriggerUtil.executeTrigger('Account')) {
   		TriggerFactory.createHandler(Account.sObjectType);
	}
    
    if (trigger.IsUpdate && trigger.isAfter) {
        ZuoraSyncController.AccountCompare ac = new ZuoraSyncController.AccountCompare(trigger.oldMap, trigger.newMap);
    }

}