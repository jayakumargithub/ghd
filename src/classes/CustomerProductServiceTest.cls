@IsTest
private class CustomerProductServiceTest { 
    @TestSetup 
    static void setup() {
        Account newAccount = new Account(
            Name = 'Test Account',
            ShippingCity = 'City',
            ShippingCountry = 'Country',
            ShippingStreet = 'Street',
            ShippingPostalCode = '123-456',
            BillingCity = 'City',
            BillingCountry = 'Country',
            BillingStreet = 'Street',
            BillingPostalCode = '123-456',
            CountryCurrency__c = 'GBP'
        );
        insert newAccount;
        
        CustomerProduct__c newProduct = new CustomerProduct__c(
            Name = 'Test Product',
            Account__c = newAccount.Id,
            PriceListRefreshedAt__c = Date.newInstance(2023, 7, 1),
            UnitPrice__c = 12.0,
            MaterialCode__c = 'CODE'
        );
        insert newProduct;
        
        Material__c newMaterial = new Material__c(
            Name = 'Material',
            MaterialDescription__c = 'searchToken',
            ProductType__c = 'Type 1',
            Category__c = 'Combs',
            MaterialCode__c = 'CODE'
        );
        insert newMaterial;
        
        DraftOrder__c newDraftOrder = new DraftOrder__c(
            Account__c = newAccount.Id,
            Description__c = 'draftName',
            CustomerProduct__c = newProduct.Id,
            OrderQty__c = 1
        );
        insert newDraftOrder;
    }
    
    @IsTest 
    static void testGetMaterialsForAccount() {
        Account newAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        
        CustomerProductService.CpWrapper cpWrapper = CustomerProductService.getMaterialsForAccount(newAccount.Id, 'searchToken', 'draftName');
        List<CustomerProductService.CustomerProductWrapper> resultList = cpWrapper.wrapperList;
        Assert.areEqual('Type 1', resultList[0].Category);
    }
    
    @IsTest
    static void testCreate(){
        Account newAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        CustomerProduct__c newProduct = [SELECT Id, Name FROM CustomerProduct__c WHERE Name = 'Test Product'];
        String jsonInput = '[{"OrderQty": 1,"Id": "' + newProduct.Id + '"}]';
        
        Boolean result = CustomerProductService.create(jsonInput, newAccount.Id, 'draftDesc', 12.0);
        Assert.areEqual(true, result);
    }
}