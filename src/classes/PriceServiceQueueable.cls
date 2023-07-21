/**
 * Created by Jayakumar Mogenahall on 19/04/2023.
 */

public class PriceServiceQueueable implements Queueable{

    List<CustomerProduct__c> customerProductList = new List<CustomerProduct__c>();
    public PriceServiceQueueable(List<CustomerProduct__c> customerProducts){
        this.customerProductList = customerProducts;
        system.debug('Look here '+this.customerProductList);
    }
    public void execute(QueueableContext param1) {
        Database.UpsertResult[] results;
        if(this.customerProductList.size() > 0 ){
            try{
                results = Database.upsert(this.customerProductList);
                System.debug('#CustomerProduct upsert result:'+ results);
            }
            catch (DmlException dmlException){
                System.debug('Error PriceServiceQueueable:' + dmlException.getMessage() + ' Stacktrace: ' + dmlException.getStackTraceString());
            }
            catch (Exception ex){
                System.debug('Error PriceServiceQueueable:' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
            }
        } else{
             System.debug('Error PriceServiceQueueable: No products');
        }
    }
}