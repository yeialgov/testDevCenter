({
    doInit : function(component, event, helper) {
        var AccountId = component.get("v.Invoice").Account__c;
        $A.createComponent(
            'c:AddressBuilder',
            {
                recordId: AccountId
            },
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