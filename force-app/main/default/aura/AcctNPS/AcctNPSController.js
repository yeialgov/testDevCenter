({
    getAcctId : function(component, event, helper) {
        var AcctId = component.get("v.AccountId");
        var action = component.get("c.getNPS");
        action.setParams({"AccountId": AcctId});
        action.setCallback(this, function(response){
            var NPSList = response.getReturnValue();
            for (var NPS of NPSList) {
                NPS.color = "goldenrod";
                NPS.desc = "neutral";
                if (NPS.NPS__c > 8) {
                    NPS.color = "green";
                    NPS.desc = "promoter";
                } else if (NPS.NPS__c < 7) {
                    NPS.color = "red";
                    NPS.desc = "detractor";
                }
            }
            component.set("v.NPS", NPSList);
        });
        $A.enqueueAction(action);
    }
})