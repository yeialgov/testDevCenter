trigger CaseTrigger on Case (after delete, after insert, after update, before delete, before insert, before update) {
	if(TriggerUtil.executeTrigger('Case')) {
   		TriggerFactory.createHandler(Case.sObjectType);
	}
}