/**
 * Created by Jayakumar Mogenahall on 07/02/2023.
 */
@IsTest
public with sharing class MaterialProcessTest {

    @IsTest
    static void testDoPut() {
        // Test data setup
        // Create test records for MaterialRequestWrapper, Dimension__c, and Material__c
        
        // Create instance of RestRequest
        RestRequest req = new RestRequest();
        req.requestURI = '/Material/*';
        req.httpMethod = 'PUT';
        
        req.requestBody = Blob.valueOf('[{"wrappers": [{"material": "M1", "materialDescription": "Description1", "Name": "Material 1", "productType": "Type1", "uom": "UOM1", "owner": "Owner1", "serialisedProduct": false, "dangerousGoodsFlag": false, "carrierBag": false, "wetStock": false, "active": true, "customsDescription": "Customs1", "dangerousGoodsClassification": "Classification1", "category": "Category1", "dangerousGoodsShippingName": "ShippingName1", "dimensions": {"dimType": "Type1", "weight": "1.0", "depth": "10.0", "height": "5.0", "volume": "50.0", "totalUnitsInCarton": "10", "totalUnitsInPallet": "100"}}]}]');
        //req.requestBody = Blob.valueOf('{"materialDescription" : "Hello World","dimensions":{"dimType":"testDimType"},"codes":{"eanCode":"Ab23"},"region":{"countryCode":"Gb"},"additionalInfo":{"info1":"tstInfo1"},"origin":{"originApplication":"OrignApp"}}');
        RestContext.request = req;
        
        // Create instance of RestResponse
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the doPut method
        Test.startTest();
        MaterialProcessNew.doPut();
        Test.stopTest();
        
        // Assert the response
        //System.assertEquals('OK', res.statusCode);
        RestResponseWrapper resWrapper = (RestResponseWrapper)JSON.deserialize(res.responseBody.toString(), RestResponseWrapper.class);
        System.assertEquals('OK', resWrapper.result);
        System.assertEquals('M1', resWrapper.data.genericId);
        
        // Add more assertions as needed
    }


//    @IsTest
//    static void Test1(){
//        Test.setMock(HttpCalloutMock.class, new CustomerProcessTest() );
//        String json = '{"materialDescription" : "Hello World","dimensions":{"dimType":"testDimType"},"codes":{"eanCode":"Ab23"},"region":{"countryCode":"Gb"},"additionalInfo":{"info1":"tstInfo1"},"origin":{"originApplication":"OrignApp"}}';
//        MaterialRequestWrapper process = new MaterialRequestWrapper;
//        System.debug('#process:'+process);
//    }

//    public HttpResponse respond(HttpRequest request) {
//        HttpResponse response = new HttpResponse();
//        response.setHeader('Content-Type','x-www-form-urlencoded');
//        response.setBody('{"result":"OK"}');
//        response.setStatusCode(200);
//        return response;
//    }
}