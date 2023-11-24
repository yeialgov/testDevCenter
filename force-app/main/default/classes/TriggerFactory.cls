/*************************************************************************
* Author:           Richard Abendroth
* Author-Email:     development@incubes.com
* Author-Website:   www.incubes.com
*
* Name:             TriggerFactory
* Type:             Service Class 
*
* Description:      - Factory class for bulkified trigger pattern
*                   - See http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
*                   for more details
*                   - Add additional handlers in getHandler
*
* Changes:          2016-11-07: Created by Richard Abendroth
*                   2017-11-03: Modified by Bart Collins for formatting
*                               and to include Case and Zuora__SubscriptionProductCharge__c
*					2018-10-22: Modified by Bart Collins again to exorcise the Zuora demons
*************************************************************************/
public with sharing class TriggerFactory {

    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
    public static void createHandler(Schema.sObjectType soType) {
        // Get a handler appropriate to the object being processed
        ITriggerHandler handler = getHandler(soType);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null) {
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
        
        // Execute the handler to fulfil the trigger
        execute(handler);
    }
    
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */ 
    private static void execute(ITriggerHandler handler) {
        // Before Trigger
        if (Trigger.isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.beforeDelete(so);
                }
            } else if (Trigger.isInsert) {
	            // Iterate through the records to be inserted passing them to the handler.
                for (SObject so : Trigger.new) {
                    handler.beforeInsert(so);
                }
            } else if (Trigger.isUpdate) {
	            // Iterate through the records to be updated passing them to the handler.
                for (SObject so : Trigger.old) {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        } else {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            if (Trigger.isDelete) {
	            // Iterate through the records deleted passing them to the handler.
                for (SObject so : Trigger.old) {
                    handler.afterDelete(so);
                }
            } else if (Trigger.isInsert) {
            	// Iterate through the records inserted passing them to the handler.
                for (SObject so : Trigger.new) {
                    handler.afterInsert(so);
                }
            } else if (Trigger.isUpdate) {
                // Iterate through the records updated passing them to the handler.
                for (SObject so : Trigger.old) {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITriggerHandler - A trigger handler if one exists or null.
     */
    private static ITriggerHandler getHandler(Schema.sObjectType soType) {
        //Add additional handlers here
        if (soType == Lead.sObjectType) {
            return new LeadHandler();
        } else if (soType == Opportunity.sObjectType) {
            return new OpportunityHandler();
        } else if (soType == Contact.sObjectType) {
            return new ContactHandler();
        } else if (soType == Account.sObjectType) {
            return new AccountHandler();
        } else if (soType == Case.sObjectType) {
            return new CaseHandler();
        } else if (soType == SubscriptionLineItem__c.sObjectType) {
            return new SubscriptionLineItemHandler();
        } else {
            return null;
        }
    }
}