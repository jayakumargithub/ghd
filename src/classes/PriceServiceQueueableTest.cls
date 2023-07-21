/**
 * Created by Jayakumar Mogenahall on 28/06/2023.
 */

@IsTest
public  class PriceServiceQueueableTest {

    @TestSetup
    public static void Setup(){
        Account acc = TestFactory.createAccount('Doe',true);
        CustomerProduct__c customerProduct1 = TestFactory.createCustomerProduct(acc.Id,'MSD Price',true);

    }

    @IsTest
    public static void executeQueueable(){
        List<CustomerProduct__c> customerProducts = [SELECT Id, Account__c FROM CustomerProduct__c];
        PriceServiceQueueable queueable = new PriceServiceQueueable(customerProducts);
        Id jobId = System.enqueueJob(queueable);
        System.assert(jobId != null);
    }
    @IsTest
    public static void executeQueueableException(){
        List<CustomerProduct__c> customerProducts = [SELECT Id, Account__c FROM CustomerProduct__c];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        CustomerProduct__c customerProduct2 = TestFactory.createCustomerProduct(acc.Id,'MSD Price',false);
        customerProduct2.PriceType__c = 'XX';
        customerProducts.add(customerProduct2);
       try {
           PriceServiceQueueable queueable = new PriceServiceQueueable(customerProducts);
           Id jobId = System.enqueueJob(queueable);
           System.debug('jobId:'+ jobId);

       }catch (DmlException ex){
           System.debug('ex:'+ex.getMessage());
           System.assert(ex.getMessage() != null);
       }


    }
}