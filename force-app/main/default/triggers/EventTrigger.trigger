/**
 * @author martin
 *
 * @todo create EventHandler (EventTrigger)
 */
trigger EventTrigger on Event (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(TriggerUtil.executeTrigger('Event')) {
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            EventStageRollup esr = new EventStageRollup(Trigger.newMap, Trigger.oldMap);
            esr.execute();
        }
    }
        
}