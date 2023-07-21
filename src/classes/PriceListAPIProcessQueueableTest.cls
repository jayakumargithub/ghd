/**
 * Created by Jayakumar Mogenahall on 28/06/2023.
 */

@IsTest
public class PriceListAPIProcessQueueableTest {

    @TestSetup
    public static void Setup(){
        Account acc = TestFactory.createAccount('Doe',true);

    }

    @IsTest
    public static void test1(){
        Map<String,String> params =  new Map<String,string>();
        Account acc = [SELECT Id FROM Account];
        params.put('customerId', acc.Id);
        //Integer code, String status, String body, Map<String, String> responseHeaders
        Test.setMock(HttpCalloutMock.class,new HTTPMockFactory(200,'OK','',params));
    }

}