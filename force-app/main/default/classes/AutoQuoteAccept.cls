global class AutoQuoteAccept implements Schedulable {
        
    global void execute(SchedulableContext sc) {
        doAutoQuoteAccept();
    }
    
    @future(callout=true)
    global static void doAutoQuoteAccept() {
        doNowAutoQuoteAccept();
    }
    
    global static void doNowAutoQuoteAccept() {
        list<quote> quotes = [select id, status from quote where AutoAcceptPriority__c != null and status = 'draft' order by AutoAcceptPriority__c];
        if(quotes.size() > 0) zuorasynccontroller.sendQuote(quotes[0].id, false);
    } 
    
}