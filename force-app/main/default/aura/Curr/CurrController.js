({
	doInit : function(component, event, helper) {
		var value = component.get("v.Value");
		var country = component.get("v.Country");
		var currency = component.get("v.Currency");
        var output = "";
        if (value >= 1000) {
            output += Math.floor(value/1000);
            output += ".";
            if (value % 1000 < 10) {
                output += "00";
            } else if (value % 1000 < 100) {
                output += "0";
            }

        }
        output += Math.floor(value % 1000);
        output += ",";
        var decval = value * 100 % 100;
        if (decval < 10) output += "0";
        output += "" + decval;
        component.set("v.Output", output + " " + currency);
	}
})