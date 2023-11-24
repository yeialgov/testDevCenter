({
    doInit : function(component, event, helper) {
        var AccountId = component.get("v.Object").Account__c;
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
    }
})