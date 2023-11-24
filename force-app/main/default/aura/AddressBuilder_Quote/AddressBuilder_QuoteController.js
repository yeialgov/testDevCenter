({
    doInit : function(component, event, helper) {
        var AccountId = component.get("v.Quote").AccountId;
        var AddressType = component.get("v.AddressType");
        $A.createComponent(
            'c:AddressBuilder',
            {
                recordId: AccountId,
                AddressType: AddressType
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