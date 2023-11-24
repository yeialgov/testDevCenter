public class SubmitPaymentGateway {
    
    @future(callout=true)
    public static void SubmitPayment() {
        try {
            Payment__c p = [
                SELECT Id, NeedsAttention__c, ZuoraId__c 
                FROM Payment__c 
                WHERE NeedsAttention__c = TRUE AND ZuoraId__c != null 
                LIMIT 1
            ];
            system.debug(ZuoraAPIManager.callZuoraAPI(
                'gateway-settlement/payments/' + p.ZuoraId__c + '/settle',
                'POST',
                '{"settledOn": "'+String.valueOf(DateTime.now())+'"}'
            ));
            p.NeedsAttention__c = false;
            update p;
        } catch(exception e) {}
    }
}