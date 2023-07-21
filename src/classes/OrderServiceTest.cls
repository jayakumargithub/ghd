@IsTest
private class OrderServiceTest {
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
        
        Material__c newMaterial = new Material__c(
            Name = 'Material',
            MaterialDescription__c = 'searchToken',
            ProductType__c = 'Type 1',
            Category__c = 'Combs',
            MaterialCode__c = 'CODE'
        );
        insert newMaterial;
        
        GhdOrder__c newGhdOrder = new GhdOrder__c(
            POReference__c = 'ref',
            Account__c = newAccount.Id,
            CountryCode__c = 'GB',
            ApprovalStatus__c = 'Approved',
            CreatedSource__c = 'Case',
            OrderType__c = 'R'
        );
        insert newGhdOrder;
        
        Origin__c newOrigin = new Origin__c(
            CountryCode__c = 'GB',
            Identifier__c = '123456',
            Application__c = 'application',
            eCommStore__c = 'eComm'
        );
        insert newOrigin;
    }
    
    @IsTest 
    static void testCreateOrderWithId(){
        Account newAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        GhdOrder__c newOrder = [SELECT Id, Account__c FROM GhdOrder__c WHERE Account__c = :newAccount.Id LIMIT 1];
        String testJSON = '{"Id":"' + newOrder.Id + '","accountId":"' + newAccount.Id + '","products":[{"Id":"67890","productName":"testProd","MaterialCode":"CODE"}]}';
        
        String accessTokenBody = '{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);
        
        String queueableCalloutBody = '{"result":"OK"}';
        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);
        
        Test.startTest();
        String result = OrderService.createOrder(testJSON);
        Test.stopTest();
        Assert.areEqual(newOrder.Id, result);
    }
    
    @IsTest 
    static void testCreateOrderWithoutId(){
        Account newAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        GhdOrder__c newOrder = [SELECT Id, Account__c FROM GhdOrder__c WHERE Account__c = :newAccount.Id LIMIT 1];
        String testJSON = '{"accountId":"' + newAccount.Id + '","products":[{"Id":"67890","productName":"testProd","MaterialCode":"CODE"}]}';
        
        String accessTokenBody = '{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);
        
        String queueableCalloutBody = '{"result":"OK"}';
        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);
        
        Test.startTest();
        String result = OrderService.createOrder(testJSON);
        Test.stopTest();
        Assert.areNotEqual(null, result);
    }
}