trigger ContactTrigger on Contact (after delete, after insert, after update, before delete, before insert, before update)
{
    if(TriggerUtil.executeTrigger('Contact')) {
        TriggerFactory.createHandler(Contact.sObjectType);
    }
}