public class AccountOrderQuery {

    
      @AuraEnabled(cacheable=true)
    public static Account createOrder(String recordId) {
   
        if(recordId.startsWithIgnoreCase('001')){
            
            return [SELECT BillingAddress,ShippingAddress FROM Account WHERE Id =: recordId];
        }
        return null;
    }
    
}