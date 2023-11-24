({
    doInit : function(component, event, helper) {
        var action = component.get("c.getTaskAccountId");
        action.setParams({"TaskId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var AccountId = response.getReturnValue();
            var AddressType = component.get("v.AddressType");
            $A.createComponent(
                'c:AddressBuilderNew', { recordId: AccountId },
                function(element, status, errorMessage){
                    if (component.isValid() && status == 'SUCCESS'){
                        var body = component.get('v.body');
                        body.push(element);
                        component.set('v.body', element);
                    }
                }
            );	
        });
        $A.enqueueAction(action);
    }
})