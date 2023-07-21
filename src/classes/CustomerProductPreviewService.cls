/**
 * Created by Jayakumar Mogenahall on 21/02/2023.
 */

public with sharing class CustomerProductPreviewService {

    @AuraEnabled(Cacheable=true)

    public static List<DraftOrder__c> getDraftViewForCustomer(String customerId) {

        List<DraftOrder__c> customerProductPreviews = [
                SELECT Id,
                        OrderQty__c,
                        Family__c,
                        ProductName__c,
                        PromotionFreeQty__c,
                        PromotionOrderQty__c,
                        UnitPrice__c,
                        FreeQty__c
                FROM DraftOrder__c
                WHERE Account__c = :customerId
        ];


        return customerProductPreviews;
    }
}