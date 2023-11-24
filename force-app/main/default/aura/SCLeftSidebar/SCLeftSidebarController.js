({
    doInit : function(component, event, helper) {
        try {
            var action1 = component.get("c.getConsoleItems");
            var Ids = [];
            action1.setCallback(this, function(response){
                var Items = JSON.parse(action1.getReturnValue());
                component.set("v.Items", Items);
                for (var a=0; a<Items.length; a++) {
                    Ids.push(Items[a].Id);
                }
            });
            $A.enqueueAction(action1);
            var x = setInterval(function() {
                //var action = component.get("c.getConsoleItems");
                var needsRefresh = false;
                action1.setCallback(this, function(response){
                    if(action1.getState() == "SUCCESS") {
                        var Items = JSON.parse(action1.getReturnValue());
                        for (var a=0; a<Items.length; a++) {
                            if (!Ids.includes(Items[a].Id)) {
                                needsRefresh = true;
                                Ids.push(Items[a].Id);
                            }
                        }
                        if (needsRefresh) {
                            component.set("v.Items", Items);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Update!",
                                "message": "The list has been updated."
                            });
                            toastEvent.fire();
                        }
                    }
                });
                $A.enqueueAction(action1);
            }, 5000);
        } catch(e) {}
    },
    removeCalled : function(component, event, helper) {
        var Items = component.get("v.Items");
        for (var x=0; x<Items.length; x++) {
            if (Items[x].Id == event.getParams().Id) Items.splice(x,1);
        }
        component.set("v.Items", Items);
    }
})