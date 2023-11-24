global class SubmitPaymentGateway_sched implements Schedulable {
    global void execute(SchedulableContext sc) {
        SubmitPaymentGateway.SubmitPayment();
    }
}