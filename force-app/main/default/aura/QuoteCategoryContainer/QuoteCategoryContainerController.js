({
	toggle : function(component, event, helper) {
		component.set("v.Hidden", false==component.get("v.Hidden"));
	},
    handleApplicationEvent : function(component, event, helper) {
        console.log(event.getParam("message"));
        var EventMsg = JSON.parse(event.getParam("message"));
        var Data = component.get("v.Data");
        if (EventMsg.ProductCategory__c == Data.Id) {
            if (Data.tDelta == null) Data.tDelta = 0;
            Data.tDelta += EventMsg.Delta;
            Data.Num += EventMsg.Delta;
            component.set("v.Data", Data);
        }
    }
})