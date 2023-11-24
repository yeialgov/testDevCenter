({
    doInit : function(component, event, helper) {
        if (component.get("v.height") == "empty") {
            var w = 800;
            try {w = component.find("div1").getElement().offsetWidth;} catch(err) {}
            var h = 1.3 * w;
            component.set("v.height", h + "px");
            var pageName = component.get("v.sObjectName").replace("__c","");
            $A.createComponent(
                "iframe",
                {
                    "src": "/apex/" + pageName + "?id=" + component.get("v.recordId"),
                    "width": "100%",
                    "height": h + "px"
                },
                function(iframe, status, errorMessage){
                    var body = component.get("v.body");
                    body.push(iframe);
                    component.set("v.body", body);
                }
            );
        }
    },
    refresh : function(component, event, helper) {
        component.set("v.body", null);
        helper.initialize(component, event, helper);
    }
})