/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_CaseTrigger on Case
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(TriggerUtil.executeTrigger('Case')) {
        dlrs.RollupService.triggerHandler();
    }
}