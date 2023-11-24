({
	getVenues : function(component, event, helper) {
        var action = component.get("c.getAccountId");
        action.setParams({"LiveChatTranscriptId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var AcctId = response.getReturnValue();
            var action2 = component.get("c.getMyObVenues");
        		action2.setParams({"AccountId": AcctId});
        		action2.setCallback(this, function(response){
            	component.set("v.Venues", response.getReturnValue());
        });
        $A.enqueueAction(action2);    
        });
    
    $A.enqueueAction(action);
	}
})