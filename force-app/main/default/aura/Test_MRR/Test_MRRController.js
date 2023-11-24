({
	doInit : function(component, event, helper) {
        var AcctId = component.get("v.recordId");
        var action = component.get("c.getMRR");
        action.setParams({"AccountId": AcctId});
        action.setCallback(this, function(response){
            var MRR = response.getReturnValue();
            if (MRR == null) MRR = 0.0;
            component.set("v.MRR", MRR);
        });
        $A.enqueueAction(action);
    }
})