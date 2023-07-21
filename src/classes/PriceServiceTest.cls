/**
 * Created by Jayakumar Mogenahall on 28/06/2023.
 */

@IsTest
public  class PriceServiceTest {
    @TestSetup
    public static void Setup(){
    Account account = TestFactory.createAccount('Doe',false);
        account.CustomerId__c = '10413668';
        account.Country_Code__c = 'GB';
        account.CountryCurrency__c = 'GBP';
        insert account;

        Account accountDE = TestFactory.createAccount('DoeDE',false);
        accountDE.CustomerId__c = '10413669';
        accountDE.Country_Code__c = 'DE';
        accountDE.CountryCurrency__c = 'EUR';
        insert accountDE;

        Account accountAu = TestFactory.createAccount('DoeDE',false);
        accountAu.CustomerId__c = '10413670';
        accountAu.Country_Code__c = 'AU';
        accountAu.CountryCurrency__c = 'AUD';
        insert accountAU;

        Account accountNz = TestFactory.createAccount('DoeDE',false);
        accountNz.CustomerId__c = '10413671';
        accountNz.Country_Code__c = 'NZ';
        accountNz.CountryCurrency__c = 'NZD';
        insert accountNz;

        Material__c material = new Material__c();
        material.Name = 'Xmas 2017 Deluxe UK';
        material.MaterialCode__c = '10000021781';
        material.MaterialDescription__c = 'Xmas 2017 Deluxe UK';
        insert material;

        CustomerProduct__c cp = new CustomerProduct__c();
        cp.Name = 'Xmas 2017 Deluxe UK';
        cp.MaterialCode__c = '10000021781';
        cp.PriceType__c = 'MSD Price';
        cp.UnitPrice__c = 90.00;
        cp.Currency__c = 'GBP';
        cp.Account__c = account.Id;
        insert cp;

        CustomerProduct__c cpDE = new CustomerProduct__c();
        cpDE.Name = 'Xmas 2017 Deluxe UK';
        cpDE.MaterialCode__c = '10000021781';
        cpDE.PriceType__c = 'MSD Price';
        cpDE.UnitPrice__c = 90.00;
        cpDE.Currency__c = 'EUR';
        cpDE.Account__c = accountDE.Id;
        insert cpDE;

        CustomerProduct__c cpAU = new CustomerProduct__c();
        cpAU.Name = 'Xmas 2017 Deluxe UK';
        cpAU.MaterialCode__c = '10000021781';
        cpAU.PriceType__c = 'MSD Price';
        cpAU.UnitPrice__c = 90.00;
        cpAU.Currency__c = 'AUD';
        insert cpAU;

        CustomerProduct__c cpNZ = new CustomerProduct__c();
        cpAU.Name = 'Xmas 2017 Deluxe UK';
        cpAU.MaterialCode__c = '10000021781';
        cpAU.PriceType__c = 'MSD Price';
        cpAU.UnitPrice__c = 90.00;
        cpAU.Currency__c = 'NZD';
        cpAU.Account__c = accountNZ.Id;
        insert cpNZ;



    }

    @IsTest
    public static void getPriceForCustomerForGBTest(){
        Account acc = [SELECT Id,CustomerId__c,CountryCurrency__c,Country_Code__c FROM Account WHERE Country_Code__c = 'GB'];

        String accessTokenBody = '{response:{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);

        String queueableCalloutBody = '{"response":{"result":"OK","serviceName":"GETPRICELIST","responseSent":"2023-06-30T09:27:49.622Z","data":{"customerAccount":"10413668","prices":{"price":[{"materialCode":"10000021781","unitPrice":127.7,"countryCurrency":"GBP","priceType":"MSD Price"}]},"countryCode":"GB"}}}';
        {}
        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);

        Test.startTest();
        PriceService.getPriceForCustomer(acc.CustomerId__c);
        Test.stopTest();
    }
    @IsTest
    public static void getPriceForCustomerForDETest(){
        Account acc = [SELECT Id,CustomerId__c,CountryCurrency__c,Country_Code__c FROM Account WHERE Country_Code__c = 'DE'];

        String accessTokenBody = '{response:{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);

        String queueableCalloutBody = '{"response":{"result":"OK","serviceName":"GETPRICELIST","responseSent":"2023-06-30T09:27:49.622Z","data":{"customerAccount":"10413669","prices":{"price":[{"materialCode":"10000021781","unitPrice":127.7,"countryCurrency":"GBP","priceType":"MSD Price"}]},"countryCode":"GB"}}}';
        {}
        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);

        Test.startTest();
        PriceService.getPriceForCustomer(acc.CustomerId__c);
        Test.stopTest();
    }
    @IsTest
    public static void getPriceForCustomerForAUTest(){
        Account acc = [SELECT Id,CustomerId__c,CountryCurrency__c,Country_Code__c FROM Account WHERE Country_Code__c = 'AU'];

        String accessTokenBody = '{response:{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);

        String queueableCalloutBody = '{"response":{"result":"OK","serviceName":"GETPRICELIST","responseSent":"2023-06-30T09:27:49.622Z","data":{"customerAccount":"10413670","prices":{"price":[{"materialCode":"10000021781","unitPrice":127.7,"countryCurrency":"GBP","priceType":"MSD Price"}]},"countryCode":"GB"}}}';
        {}
        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);

        Test.startTest();
        PriceService.getPriceForCustomer(acc.CustomerId__c);
        Test.stopTest();
    }

    @IsTest
    public static void getPriceForCustomerForNZTest(){
        Account acc = [SELECT Id,CustomerId__c,CountryCurrency__c,Country_Code__c FROM Account WHERE Country_Code__c = 'NZ'];
        //String testJSON = '{"Id":"' + newOrder.Id + '","accountId":"' + newAccount.Id + '","products":[{"Id":"67890","productName":"testProd","MaterialCode":"CODE"}]}';


        String accessTokenBody = '{response:{"access_token":"18927981","token_type":"access","expires_in": 1200}';
        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, accessTokenMock);

        String queueableCalloutBody = '{"response":{"result":"OK","serviceName":"GETPRICELIST","responseSent":"2023-06-30T09:27:49.622Z","data":{"customerAccount":"10413671","prices":{"price":[{"materialCode":"10000021781","unitPrice":127.7,"countryCurrency":"GBP","priceType":"MSD Price"}]},"countryCode":"GB"}}}';
        {}
        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);

        Test.startTest();
        PriceService.getPriceForCustomer(acc.CustomerId__c);
        Test.stopTest();
    }
//    @IsTest
//    public static void getPriceForCustomerForNZTest(){
//        Account acc = [SELECT Id,CustomerId__c,CountryCurrency__c,Country_Code__c FROM Account WHERE Country_Code__c = 'NZ'];
//        //String testJSON = '{"Id":"' + newOrder.Id + '","accountId":"' + newAccount.Id + '","products":[{"Id":"67890","productName":"testProd","MaterialCode":"CODE"}]}';
//
//
//        String accessTokenBody = '{response:{"access_token":"18927981","token_type":"access","expires_in": 1200}';
//        HttpMockFactory accessTokenMock = new HttpMockFactory(200, 'OK', accessTokenBody, new Map<String,String>());
//        Test.setMock(HttpCalloutMock.class, accessTokenMock);
//
//        String queueableCalloutBody = '{"response":{"result":"OK","serviceName":"GETPRICELIST","responseSent":"2023-06-30T09:27:49.622Z","data":{"customerAccount":"10413671","prices":{"price":[{"materialCode":"10000021781","unitPrice":127.7,"countryCurrency":"GBP","priceType":"MSD Price"}]},"countryCode":"GB"}}}';
//        {}
//        HttpMockFactory queueableCalloutMock = new HttpMockFactory(200, 'OK', queueableCalloutBody, new Map<String,String>());
//        Test.setMock(HttpCalloutMock.class, queueableCalloutMock);
//
//        Test.startTest();
//        PriceService.getPriceForCustomer(acc.CustomerId__c);
//        Test.stopTest();
//    }
}