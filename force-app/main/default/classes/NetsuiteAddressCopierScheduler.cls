global class NetsuiteAddressCopierScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        NetsuiteAddressCopier b = new NetsuiteAddressCopier(); 
        database.executebatch(b);
    }
}