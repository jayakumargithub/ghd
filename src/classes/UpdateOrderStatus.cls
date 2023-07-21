/**
 * Created by Jayakumar Mogenahall on 21/03/2023.
 */

@RestResource(UrlMapping='/UpdateOrderStatus/*')
global with sharing class UpdateOrderStatus {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        System.debug('###response received:' + req.requestBody.toString());



        OrderUpdateStatusWrapper orderUpdateStatusWrapper = (OrderUpdateStatusWrapper)JSON.deserialize(req.requestBody.toString(),OrderUpdateStatusWrapper.class);
        System.debug('#orderUpdateStatusWrapper:'+orderUpdateStatusWrapper);

        if(orderUpdateStatusWrapper != null){

            List<GhdOrder__c> orders = [SELECT Id, Status__c,POReference__c FROM GhdOrder__c WHERE OrderNumber__c =: orderUpdateStatusWrapper.customerOrderCode];
            System.debug('#orders:'+orders);
            if(orders.size() > 0){
                if(orderUpdateStatusWrapper.orderStatus == 'ERP_ACCEPT'){
                    orders[0].Status__c = 'Created';
                    update orders;
                }
                res.statusCode = 200;
                res.responseBody = Blob.valueOf( '{"result":"OK"}' );
            }else {
                res.statusCode = 401;
                res.responseBody = Blob.valueOf('{"result":"warning","message":"customerOrderCode : "' + orderUpdateStatusWrapper.customerOrderCode + '" not found"}') ;
            }
        }
    }


    public class OrderUpdateStatusWrapper{
        public String customerOrderCode;
        public String fulfilmentSystemOrderCode;
        public String orderStatus;
        public String statusDescription;
    }

}