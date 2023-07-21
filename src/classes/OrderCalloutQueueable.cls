/**
 * Created by Jayakumar Mogenahall on 20/03/2023.
 */

public class OrderCalloutQueueable implements Queueable, Database.AllowsCallouts{

    OrderRequestWrapper wrapper;
    Set<String> insertedOrders = new Set<String>();
    public OrderCalloutQueueable(OrderRequestWrapper requestWrapper,Set<String> insertedOrderIds){
        this.wrapper = requestWrapper;
        this.insertedOrders = insertedOrderIds;
    }
    public void execute(QueueableContext param1) {
        Finalizer finalizer = new OrderCalloutQueueableFinalizer(this.wrapper, this.insertedOrders);
       	System.attachFinalizer(finalizer);   

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        GhdApiAccessTokenRequestService.AccessTokenWrapper accessTokenService;
        accessTokenService = GhdApiAccessTokenRequestService.getGhdApiAccessToken();
        GHD_meta_values__mdt  orderUrl = GHD_meta_values__mdt.getInstance('OrderCreationURL');
        System.debug('#orderUrl:'+orderUrl);
        GHD_meta_values__mdt  baseUrl = GHD_meta_values__mdt.getInstance('GHDBaseURL');
        System.debug('#baseUrl:'+baseUrl);
        System.debug('#orderUrl:'+orderUrl.Value__c);
        req.setEndpoint(baseUrl.Value__c + orderUrl.Value__c);
        req.setMethod('POST');
        req.setHeader('Authorization','bearer' + ' ' + accessTokenService.access_token);
       // req.setHeader('Authorization','bearer' + ' ' + 'eyJraWQiOiJkZWZhdWx0IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJTRkRDVGVzdCIsImF1ZCI6IlNGRENUZXN0IiwiZG9tYWluIjoiMjVkODY1YmQtNDQ4Mi00NmFmLTk4NjUtYmQ0NDgyNzZhZjVhIiwiaXNzIjoiaHR0cHM6XC9cL2FtLWdhdGV3YXkuZ2hkY29yZXRlc3QuY29tXC9naGRjb3JldGVzdGRvbWFpblwvb2lkYyIsImV4cCI6MTY4MTQ2OTg3MywiaWF0IjoxNjgxNDYyNjczLCJqdGkiOiJxbDZTVHpFODlaeFBmR28tR2FPOXJLbWdEY0tqZWwtLWxlTTBZM1YzWE44In0.xSOTIYF5mYUIDRxinYJWEQOB_j1VorILSiJnG-Fzm1urqrHt2lyPzkVucTDh8LwVhVKDgMMRDIdXymyIvwvSR8u5DOLaOqw-5U4QgX0XypiGj_Jw5fCodoinoU3DMVt_t13kpP1eZvDd3nYhLzHhUqGQJHDV4yAl1wqEj6zvM3cIQowX2JxE0kQIqX6WpDZBYxfhWSXUbJ1F3f8UoL_URzGO4Cwg10m7C1cjREf5YcAiUHTJ6G-ibn8h-xLPKw_bmdGFfz7GmjHt_bRdKcHOQflt89ywtk4wOBF_Fykbaj463CJOHezGn_OqWi67fbE1siA93BoB7ZRLCKxZP2gyAg');

        System.debug('# send to msd this.wrapper:'+this.wrapper);
        String jsonRequestInput =   JSON.serialize(this.wrapper);
        System.debug('jsonRequestInput:'+jsonRequestInput);
        req.setBody(jsonRequestInput);
        HttpResponse response = http.send(req);

        System.debug('#response1:'+response.getBody());
        if(response.getBody() == '{"result":"OK"}'){
            try {
                List<GhdOrder__c> orders = [SELECT Id, Status__c FROM GhdOrder__c WHERE Id IN :this.insertedOrders];
                System.debug('##orders:' + orders);
                List<GhdOrder__c> orderToUpdate = new List<GhdOrder__c>();
                for (GhdOrder__c order : orders) {
                    order.Status__c = 'Sent to MSD';
                    orderToUpdate.add(order);
                }
                System.debug('##orderToUpdate:' + orderToUpdate);
                if (orderToUpdate.size() > 0) {
                    update orderToUpdate;
                }
            }
            catch (DmlException ex){
              System.debug('DML Error - OrderCalloutQueueable: '+ ex.getMessage());
            }
            catch (Exception ex){
                System.debug('Error - OrderCalloutQueueable: '+ ex.getMessage());
            }

        }
    }
}