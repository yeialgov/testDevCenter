({
    doInit : function(component, event, helper) {
        var action = component.get("c.getCaseId");
        action.setParams({"LiveChatTranscriptId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var CaseId = response.getReturnValue();
            $A.createComponent(
                'c:CaseSolutionPicker', { recordId: CaseId },
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