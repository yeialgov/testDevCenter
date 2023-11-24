@RestResource(urlMapping='/fiscalize')
global class FiscalizationAPI {

    @HttpGet
    global static void RevokeTSE() {
        List<String> MyObVenueIds = new List<String>();
        for (MyObVenue__c venue : [
            SELECT Id, MyOrderbirdId__c, TSE_Revoke__c
            FROM MyObVenue__c
            WHERE TSE_Revoke__c >= LAST_n_DAYS:7
        ]) {
            MyObVenueIds.add(venue.MyOrderbirdId__c);
        }
        System.RestContext.response.responseBody = Blob.valueOf(JSON.serialize(MyObVenueIds));
    }
	
    @HttpPost
    global static void WizardComplete() {
        RestRequest req = System.RestContext.request;
        Map<String,Object> reqMap = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
		system.debug(json.serialize(reqMap));
        String venueId = (String)reqMap.get('venueId');
        List<MyObVenue__c> MyObVenue = [SELECT Id, Wizard_Complete__c FROM MyObVenue__c WHERE MyOrderbirdId__c = :venueId];
        if (MyObVenue.size() == 1) {
            MyObVenue[0].Wizard_Complete__c = DateTime.now();
            try {
                update MyObVenue;
                System.RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(true, new List<ErrorReasonWrapper>())));
            } catch(exception e) {
                system.debug(e.getMessage().unescapeHtml4());
                try {
                    System.RestContext.response.responseBody = Blob.valueOf(
                        JSON.serialize(
                            new ResponseWrapper(
                                false, 
                                new List<ErrorReasonWrapper>{ (ErrorReasonWrapper)JSON.deserialize(e.getMessage().unescapeHtml4().split('%%')[1], ErrorReasonWrapper.class) }
                            )
                        )
                    );
                } catch (exception ee) {
                    system.debug(ee.getMessage());
                    System.RestContext.response.responseBody = Blob.valueOf(
                        JSON.serialize(new ResponseWrapper( false, new List<ErrorReasonWrapper>{ (ErrorReasonWrapper)JSON.deserialize('{"errorCode":"0","errorMessage":"Unknown error."}', ErrorReasonWrapper.class) }
                            )
                        )
                    );
                }
            }
        } else {
            System.RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(
                    new ResponseWrapper(
                        false, 
                        new List<ErrorReasonWrapper>{ (ErrorReasonWrapper)JSON.deserialize('{"errorCode":"1","errorMessage":"Unknown customer."}', ErrorReasonWrapper.class) }
                    )
                )
            );
        }
    }
    
    public class ResponseWrapper {
        public Boolean Success { get; set; }
        public List<ErrorReasonWrapper> ErrorReasons { get; set; }
        public ResponseWrapper(Boolean IsSuccess, List<ErrorReasonWrapper> ErrorCodes) {
            Success = IsSuccess;
            ErrorReasons = ErrorCodes;
        }
    }
    
    public class ErrorReasonWrapper {
        public String errorCode { get; set; }
        public String errorMessage { get; set; }
    }
}