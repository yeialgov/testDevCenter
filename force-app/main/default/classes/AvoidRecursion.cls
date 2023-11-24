/**
 * Avoid recursive trigger execution.
 * Static in Salesforce are per transaction so the value will be true 
 * only for the current transaction and will be initialized to true 
 * for other transactions.
 * 
 * Usage:
 * trigger updateTrigger on anyObject(after update) {
 *   if(AvoidRecursion.isFirstRun()) {
 *   //write your code here            
 *   }
 * }
 *
 * @deprecated
 */
public class AvoidRecursion {
	
	private static boolean run = true;
    

    public static boolean isFirstRun() {
    	if(run) {
     		run = false;
     		return true;
    	} else {
        	return run;
    	}
    }


    public static void unset() {
        run = true;
    }
}