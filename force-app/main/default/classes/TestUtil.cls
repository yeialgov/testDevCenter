/*************************************************************************
*
*   Author:         Richard Abendroth
*   Author-Email:   development@incubes.com
*   Author-Website: www.incubes.com
*
*   Name:           TestUtil
*   Type:           UtilClass
*
*   Description:    - Used to encapsule test generated context.
*
*************************************************************************/
public class TestUtil {
        
    /* Complete Test Setups */
     
    /*
     * Setup with:
     * 1 Account
     * 3 Contacts
     * 2 Opportunities
     */
/*    public static void AccountSetup01(){
        Account acc = GetAccount();
        insert acc;
        
        List<Contact> contactsToInsert = new List<Contact>();
        for (integer x = 0; x <=3; x++){
            contactsToInsert.add(GetContact(acc.Id));
        }
        
        insert contactsToInsert;
        
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        for (integer x = 0; x <=3; x++){
            oppsToInsert.add(GetOpportunity(acc.Id, 'Test ' + x));
        }
        
        insert oppsToInsert;        
    }*/
    
    /* Single Records */
 
    public static Account getAccount(){
        Account acc = new Account(Name = 'Company');
        return acc;
    }
/*    
    public static Contact getContact(Id accountId){
        Contact con = new Contact(AccountId = accountId, LastName = 'LastName', email = 'test@incubes.com');
        return con;
    }
     
    public static Opportunity getOpportunity(Id accountId, string name){
        Opportunity opp = new Opportunity(
            Name = name,
            AccountId = accountId,
            StageName = 'Qualification',
            CloseDate = Date.today()   
        );
        return opp;       
    } 
*/    
}