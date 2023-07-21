@IsTest
private class CreateCustomerProcessTest {
    @TestSetup 
    static void setup() {
        Origin__c newOrigin = new Origin__c(
            eCommStore__c = 'commStore',
            CountryCode__c = 'GB',
            Identifier__c = 'identifier',
            Application__c = 'application'
        );
        insert newOrigin;
        
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
            CountryCurrency__c = 'GBP',
            Origin__c = newOrigin.Id
        );
        insert newAccount;
        
        AdditionalInfo__c newInfo = new AdditionalInfo__c(
            Account__c = newAccount.Id,
            Info1__c = 'info 1',
            Info2__c = 'info 2',
            Info3__c = 'info 3',
            Info4__c = 'info 4',
            Info5__c = 'info 5'
        );
        insert newInfo;
    }
    
    @IsTest 
    static void testCreateCustomer() {
        Account newAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        List<Id> idsList = new List<Id>();
        idsList.add(newAccount.Id);
        
        String accessTokenBody = '{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);
        
        String createBody = '{"body":"test"}';
        HttpMockFactory createMock = new HttpMockFactory(200, 'OK', createBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, createMock);
        
        Test.startTest();
        CreateCustomerProcess.createCustomer(idsList);
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, MSD_Status__c FROM Account WHERE Id = :newAccount.Id];
        Assert.areEqual('Saved in MSD', updatedAccount.MSD_Status__c);
    }
}