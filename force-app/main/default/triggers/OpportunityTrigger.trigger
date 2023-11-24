trigger OpportunityTrigger on Opportunity (after delete, after insert, after update, before delete, before insert, before update)
{
    if(TriggerUtil.executeTrigger('Opportunity')) {
        TriggerFactory.createHandler(Opportunity.sObjectType);
    }
}