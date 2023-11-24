({
	getAcctId : function(component, event, helper) {
        var action = component.get("c.getAccountId");
        action.setParams({"LiveChatTranscriptId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            component.set("v.AcctId", response.getReturnValue());
        });
        $A.enqueueAction(action);    
		
	}
})