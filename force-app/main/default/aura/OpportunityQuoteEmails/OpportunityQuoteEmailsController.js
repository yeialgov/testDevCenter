({
	doInit : function(component, event, helper) {
        var action = component.get("c.getEmails");
        action.setParams({"OpportunityId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var Emails = response.getReturnValue();
            for (var x in Emails) {
                console.log(Emails[x].MessageDate);
                Emails[x].MessageDateX = new Date(Emails[x].MessageDate);
                console.log(Emails[x].MessageDateX);
            }
            component.set("v.Emails", Emails);
        });
        $A.enqueueAction(action);
	}
})