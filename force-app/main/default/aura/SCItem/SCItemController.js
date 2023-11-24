({
    doInit : function(component, event, helper) {
        var Item = component.get("v.Item");
        var StartTime = new Date(Item.CreatedDate).getTime();
        var x = setInterval(function() {
            var PreseTime = new Date().getTime();
            var ReturnVal = Math.round((PreseTime - StartTime)/3000);
            var TmRemaing = PreseTime - StartTime;
            var minutes = Math.floor(TmRemaing / (1000 * 60));
            var seconds = Math.abs(Math.floor((TmRemaing % (1000 * 60)) / 1000));
            var extraZe = "";
            if (seconds < 10) extraZe = "0";
            component.set("v.CountdownClock", minutes + ":" + extraZe + seconds);
            component.set("v.CountdownValue", ReturnVal);
        }, 1000);
    },
    Clicked : function(component, event, helper) {
        var redirect = $A.get("e.force:navigateToSObject");
        redirect.setParams({
            "recordId": component.get("v.Item").Id
        });
        redirect.fire();
    }
})