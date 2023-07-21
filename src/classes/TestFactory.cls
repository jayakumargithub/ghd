/**
 * Created by Jayakumar Mogenahall on 28/06/2023.
 */

public class TestFactory {

    public static Account createAccount(string lastName, Boolean canInsert){
        Account acc = new Account();
        acc.Name = lastName;
        acc.FirstName__c = 'John';
        acc.LastName__c = 'Doe';
        acc.Primary_Email__c = 'doe@gmail.com';
        acc.Phone = '121212122';
        acc.CountryCurrency__c = 'GBP';
        acc.Origin__c = createOrigin('GB').Id;
        if(canInsert){
            insert acc;
        }
        return acc;
    }

    public static Origin__c createOrigin(string country){
        Origin__c  o = new Origin__c();
        o.Application__c = 'SFDC';
        o.Identifier__c = 'P2';
        o.eCommStore__c = 'ghd-Uk';
        o.CountryCode__c = country;
        insert o;
        return o;
    }
    public static DraftOrder__c createDraftOrder(string accountId,Boolean canInsert) {
        DraftOrder__c draftOrder = new DraftOrder__c();
        draftOrder.OrderQty__c = 1;
        draftOrder.ProductName__c = 'Test';
        draftOrder.Family__c = 'test1';
        draftOrder.Account__c = accountId;
        if (canInsert) {
            insert draftOrder;
        }
        return draftOrder;
    }
    public static CustomerProduct__c createCustomerProduct(string accountId,string priceType, Boolean canInsert){
        CustomerProduct__c  customerProduct = new CustomerProduct__c();
        customerProduct.Name ='Test1';
        customerProduct.Account__c = accountId;
        customerProduct.PriceType__c = priceType;
        if(canInsert){
            insert customerProduct;
        }
        return customerProduct;
    }


    public static Id getRecordTypeId(String recordTypeName){
        Map <String,Schema.RecordTypeInfo> recordTypeInfoMap = GhdOrder__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id recordTypeId = recordTypeInfoMap.get(recordTypeName).getRecordTypeId();
        System.debug(recordTypeId);
        return recordTypeId;
    }
}