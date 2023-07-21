/**
 * Created by Jayakumar Mogenahall on 25/06/2023.
 */

public with sharing class OrderCalloutQueueableFinalizer implements Finalizer{
    OrderRequestWrapper wrapper;
    Set<String> ids;
    public OrderCalloutQueueableFinalizer(OrderRequestWrapper requestWrapper,Set<String> insertedOrderIds){
        this.wrapper = requestWrapper;
        this.ids = insertedOrderIds;

    }
    public void execute(FinalizerContext ctx) {
        String parentJobId = ctx.getAsyncApexJobId();
        System.debug('###ctx.getResult():'+ctx.getResult());
        if(ctx.getResult() == ParentJobResult.SUCCESS){
            //do nothing
            System.debug('### Parent queueable jobId =>' + parentJobId + ' completed successfully.');
        }else{
            System.debug('### Parent queueable job =>' + parentJobId + ' failed due to unhandled exception: ' + ctx.getException().getMessage());
            //enqueue failed job
            String newJobId = System.enqueueJob(new OrderCalloutQueueable(this.wrapper,this.ids));
            System.debug('### Enqueued new jobId=> ' + newJobId);
        }
        System.debug('### Completed: execution of finalizer attached to queueable job => ' + parentJobId);
    }
}