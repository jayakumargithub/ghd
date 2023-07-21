/**
 * Created by Jayakumar Mogenahall on 01/02/2023.
 */

@IsTest
public with sharing class CustomerProcessTest{

    @TestSetup
    static void Setup(){
        Account account = TestFactory.createAccount('Doe',false);
        account.CustomerId__c = '12345678';
        account.FirstName__c = 'John';
        account.Phone = '02023002343';
        account.CustomerGroup__c = 'TestGroup';
        account.Name = account.FirstName__c +' ' + account.LastName__c;
        insert account;

        Origin__c origin = new Origin__c();
        origin.Application__c = 'SFDC';
        origin.Identifier__c = 'CRM';
        origin.CountryCode__c = 'GB';
        insert origin;
    }
    @IsTest
    static void updatingAccount(){


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customer';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');


        string xJson = '[{"CustomerData":{"localCustomerId":"12345678","creditLimit":"1000","creditLimitAvailable":"400","erpCustomerId":"12345678","customerGroup":"testGroup","customerName":"Super Man2 ","deliveryAddressLine1":"","deliveryAddressLine2":"","deliveryAddressLine3":"","deliveryTown":"","deliveryCounty":"","deliveryPostCode":"","deliveryCountryCode":"","invoiceAddressLine1":"","invoiceAddressLine2":"","invoiceAddressLine3":"","invoiceCountryCode":"","invoiceTown":"","invoiceCounty":"","invoicePostcode":"","emailAddress":"super@gmail.com","telephoneNumber":"8029293939","countryCurrency":"GBP","salesSegment":"","taxNumber":"","salesTaxNumber":"","accountStatus":"","blockStatus":"","etag":"","codePorte":""},"origin":{"originApplication":"SF","originIdentifier":"SF123","countryCode":"GB","eCommStore":"GHD Store"}}]';
        req.requestBody = Blob.valueOf(xJson);
        HttpMockFactory httpMock = new HttpMockFactory(200, 'OK', xJson, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, httpMock);

        Test.startTest();
        RestContext.request = req;
        RestContext.response= res;
         CustomerProcess.doPost();
        Test.stopTest();
        System.debug(res);
    }

    @IsTest
    static void updatingAccountWithoutLastNameCauseError(){
//        Origin__c origin = [SELECT Id,Identifier__c,Application__c,CountryCode__c,DataAreaId__c FROM Origin__c];
//        origin.Identifier__c = '';
//        origin.Application__c = '';
//        origin.CountryCode__c = '';
//        origin.DataAreaId__c = 'Test';
//        update origin;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customer';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json');
        string xJson = '[{"CustomerData":{"localCustomerId":"12345678","creditLimit":"1000","creditLimitAvailable":"400","erpCustomerId":"12345678","customerGroup":"testGroup","customerName":"Super Man2 ","deliveryAddressLine1":"","deliveryAddressLine2":"","deliveryAddressLine3":"","deliveryTown":"","deliveryCounty":"","deliveryPostCode":"","deliveryCountryCode":"","invoiceAddressLine1":"","invoiceAddressLine2":"","invoiceAddressLine3":"","invoiceCountryCode":"","invoiceTown":"","invoiceCounty":"","invoicePostcode":"","emailAddress":"super@gmail.com","telephoneNumber":"8029293939","countryCurrency":"GBP","salesSegment":"","taxNumber":"","salesTaxNumber":"","accountStatus":"","blockStatus":"","etag":"","codePorte":""},"origin":{"originApplication":"","originIdentifier":"","countryCode":"","eCommStore":"","dataAreaRead":"test"}}]';
        req.requestBody = Blob.valueOf(xJson);
        HttpMockFactory httpMock = new HttpMockFactory(200, 'OK', xJson, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, httpMock);

        Test.startTest();
        RestContext.request = req;
        RestContext.response= res;
        CustomerProcess.doPost();
        Test.stopTest();
    }


    @IsTest
    static void updateCustomerWhoIsNotExistsInTheSystem(){
        List<Account> accounts = [SELECT Id,FirstName__c FROM Account WHERE CustomerId__c =: '12345678'];
        accounts[0].CustomerId__c = '93939393';
        update accounts;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/customer';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        String jsonStr = '{"customerId":"12345678","customerType":"Salon","firstName":"John1","phone":"1234567","origin": {"originApplication":"testOriginApp","originIdentifier":"1234","countryCode":"GB"}, "additionalInfo": {"info1":"testInfo1"}}';
        req.requestBody = Blob.valueOf(jsonStr);

        Test.startTest();
        RestContext.request = req;
        RestContext.response= res;
        CustomerProcess.doPost();
        Test.stopTest();
       // System.debug(res);
      //  System.assert(res.statusCode == 401);
    }




}