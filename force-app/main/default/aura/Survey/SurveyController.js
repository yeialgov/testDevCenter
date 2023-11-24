({
    doInit : function(component) {
        var Lead = component.get("v.Lead");
        component.set("v.NPSChoice", parseInt(Lead, 10));
        var action = component.get("c.InitSurvey");
        action.setParams({
            "token": component.get("v.token"),
            "Lead": Lead
        });
        console.log(component.get("v.token"));
        console.log(Lead);
        action.setCallback(this, function(response){
            component.set("v.ShowSurvey",response.getReturnValue());
            component.set("v.ShowError",!response.getReturnValue());
        });
        $A.enqueueAction(action);        
    },
    Submit : function(component) {
        var Payload = {};
        Payload.NPS = component.get("v.NPSChoice").toString();
        Payload.Comment = component.get("v.Comment");
        var action = component.get("c.SubmitSurvey");
        action.setParams({
            "token": component.get("v.token"),
            "Payload": JSON.stringify(Payload)
        });
        action.setCallback(this, function(response){
            component.set("v.ShowSurvey",!response.getReturnValue());
            component.set("v.ShowThanks",response.getReturnValue());
        });
        $A.enqueueAction(action);        
    }
})