/*************************************************************************
* Author:           Richard Abendroth
* Author-Email:     development@incubes.com
* Author-Website:   www.incubes.com
*
* Name:             LeadTrigger
* Type:             Trigger
*
* Description:      - Bulkified Trigger for Lead sObject
*                   - See http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
*                   for more details
*                   - See Template_TriggerHandler.apxc for a handler template
*
* Changes:          2016-11-07: Created by Richard Abendroth
*************************************************************************/
trigger LeadTrigger on Lead (after delete, after insert, after update, before delete, before insert, before update)
{
    if(TriggerUtil.executeTrigger('Lead')) {
        TriggerFactory.createHandler(Lead.sObjectType);
    }
}