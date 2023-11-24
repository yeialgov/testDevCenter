/**
 * @author Bart
 */
public class AccountOnboardingStatus {
    
    // Updates Accounts if Onboarding Status should change
    public static void process(Set<Id> AccountIds, List<Account> UpdateAccounts) {

        // Query map of related onboarding cases and subscriptions
        Map<Id, SObject> AccountMap = new Map<Id, SObject>([
            SELECT Id, (
                SELECT Id, Status, CreatedDate, ClosedDate
                FROM Cases 
                WHERE 
                    Onboarding_Status_Relevant__c = True
                	//RecordType.Name = 'Case: Onboarding'
                    AND Status != 'Closed as Duplicate'
                ORDER BY CreatedDate DESC 
            ), (
                SELECT Id 
                FROM SubscriptionLineItems__r
                WHERE Product__r.Onboarding_Status_Relevant__c = True
            )
            FROM Account
            WHERE Id IN :AccountIds
        ]);
        
        // Iterate through accounts to determine correct Onboarding Status and only update for changes
        for (Integer x = UpdateAccounts.size()-1 ; x >= 0 ; x--) {
            
            // Get list of related subscriptions (if any)
            List<SObject> RelatedSubscriptions = AccountMap.get(UpdateAccounts[x].Id).getSObjects('SubscriptionLineItems__r');
            
            // Get list of related cases (if any)
            List<SObject> RelatedCases = AccountMap.get(UpdateAccounts[x].Id).getSObjects('Cases');
            
            // Determine if related subscriptions or cases exist
            Boolean HasCase = RelatedCases != null;
            Boolean HasSubscription = RelatedSubscriptions != null;
            
            // Check to see if Case pre-dates Go-live
            if (HasCase && !HasSubscription) {
                DateTime FirstCaseDateTime = (DateTime)(RelatedCases[RelatedCases.size()-1].get('CreatedDate'));
                DateTime CutOffDateTime = DateTime.newInstance(2017, 9, 4);
                if (FirstCaseDateTime < CutOffDateTime) HasSubscription = true;
            }
            
            // Determine correct onboarding message 
            String OnboardingMessage = Label.ONBOARDSTATUS_NOSUB;
            Date OnboardingClosedDate = null;
            if (HasSubscription) {
                if (HasCase) {
                    OnboardingMessage = getStatusMessage((String)RelatedCases[0].get('Status'));
                    try{
                        DateTime cd = (DateTime)RelatedCases[0].get('ClosedDate');
                        OnboardingClosedDate = Date.newInstance(cd.year(), cd.month(), cd.day());
                    }catch(exception e){}
                } else {
                    OnboardingMessage = Label.ONBOARDSTATUS_NOCASE;
                }
            } else if (HasCase) {
                OnboardingMessage = Label.ONBOARDSTATUS_CASENOSUB + ' (' + getStatusMessage((String)RelatedCases[0].get('Status')) + ')';
                try{
                    DateTime cd = (DateTime)RelatedCases[0].get('ClosedDate');
                    OnboardingClosedDate = Date.newInstance(cd.year(), cd.month(), cd.day());
                }catch(exception e){}
            }
            
            // If there is a difference between database and determined value, replace value. Otherwise, remove from list.
            if (OnboardingMessage != UpdateAccounts[x].Onboard_Status__c) {
                UpdateAccounts[x].Onboard_Status__c = OnboardingMessage;
                if (UpdateAccounts[x].OnboardingClosedDate__c == null) UpdateAccounts[x].OnboardingClosedDate__c = OnboardingClosedDate;
            } else {
                UpdateAccounts.remove(x);
            }
            
        }
        
        // Make database update to commit correct status
        update UpdateAccounts;
        
    }
    
    // Used by triggers
    public static void process(Set<Id> AccountIds) {
        
        // Query accounts
        List<Account> UpdateAccounts = [SELECT Id, Onboard_Status__c FROM Account WHERE Id IN :AccountIds];
        
        process(AccountIds, UpdateAccounts);
        
    }
    
    // Used by batch jobs
    public static void process(List<Account> UpdateAccounts) {
        
        // Create set of Account Ids
        Set<Id> AccountIds = new Set<Id>();
        for (Account UpdateAccount : UpdateAccounts) {
            AccountIds.add(UpdateAccount.Id);
        }
        
        process(AccountIds, UpdateAccounts);
        
    }
    
    // Replace Case Statuses with User-friendly Onboarding Statuses as appropriate
    public static Map<String, String> MessageMap = new Map<String, String>{
        'Closed' => 'Completed',
        'Closed - Not Solved' => 'Closed/Uncompleted'
    };
    
    // Only Return User-friendly Onboarding Status where one is mapped, otherwise display Case Status
    public static String getStatusMessage(String Status) {
        String Message = MessageMap.get(Status);
        if (Message == null) { return Status; } else { return Message; }
    }
    
}