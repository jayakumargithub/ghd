public class DateCodeCheckerHandler {

public class Input {
         @invocableVariable
         public String dateCode;

        @invocableVariable
        public Case caseToCheck;
        
        @invocableVariable
    	public OrderLineItem__c  lineItemToCheck;
    }
      public class Output{
    @InvocableVariable public List<String> result;
    public Output(List<String> obj) {this.result = obj;}
  }

    @InvocableMethod(Callout=true)
    public static void checkDateCode(List<Input> input){
        OrderLineItem__c  lineItemToCheck;
        Case caseToCheck;
        String dateCode;
        DateCodeResponseWrapper returnResponse;
        List<String> result = new List<String>();
        for(Input check: input){
            if(check.caseToCheck != null){
                caseToCheck = check.caseToCheck;
               returnResponse = handleRequest(caseToCheck,null);
            
            }else
            
            if(check.lineItemToCheck != null){
                lineItemToCheck = check.lineItemToCheck;
               returnResponse = handleRequest(null,lineItemToCheck);
                  if(lineItemToCheck.DateCode__c==null){
             lineItemToCheck.DateCode__c= dateCode;
                
            }
            }
           else if(check.dateCode != null){
                dateCode = check.dateCode;
               returnResponse = handleDateCode(dateCode);
            }
        } 
        System.debug(returnResponse);
       result.add(returnResponse.productName);
       result.add(returnResponse.productType);
       result.add(returnResponse.validationCode);
        if(lineItemToCheck!=null){
            lineItemToCheck.T_T_Product_Name__c = returnResponse.productName;
            lineItemToCheck.T_T_Product_Type__c = returnResponse.productType;
            lineItemToCheck.T_T_Product_Status__c = returnResponse.validationCode;
          
            update lineItemToCheck;
        }else if(caseToCheck!=null){
           caseToCheck.T_T_Product_Name__c = returnResponse.productName;
           caseToCheck.T_T_Product_Type__c = returnResponse.productType;
           caseToCheck.T_T_Product_Status__c = returnResponse.validationCode;
            
           update caseToCheck;
        }
      
    }
    public static DateCodeResponseWrapper handleDateCode(String dateCode){
      String jsonBody = buildBody(dateCode);  
     String response = callout(jsonBody);
     DateCodeResponseWrapper dcw = (DateCodeResponseWrapper)System.JSON.deserialize(response, DateCodeResponseWrapper.class);
     return dcw;
    }
    public static DateCodeResponseWrapper handleRequest(Case newCase ,OrderLineItem__c lineItemToCheck){
       String dateCode;
        
        try{
            if(newCase.Date_Code__c!= null){
                
             dateCode = newCase.Date_Code__c ;
                
            }  
             }catch(Exception e){
            
        }
          try{
            if(lineItemToCheck.DateCode__c!= null){
                
             dateCode = lineItemToCheck.DateCode__c ;
                
            }   
        }catch(Exception e){
            
        }
        
       String jsonBody = buildBody(dateCode);
      String response = callout(jsonBody);
     DateCodeResponseWrapper dcw = (DateCodeResponseWrapper)System.JSON.deserialize(response, DateCodeResponseWrapper.class);
       
     return dcw;
        
    }
    
   public static String buildBody(String dateCode) {
       String body;
       DateCodeWrapper dcw = new DateCodeWrapper();
       dcw.dateCode = dateCode;
       dcw.source = 'RETURNS';
       body = JSON.serialize(dcw);
       return body;
   }

   public static String callout(String jsonBody) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        GhdApiAccessTokenRequestService.AccessTokenWrapper accessTokenService = GhdApiAccessTokenRequestService.getGhdApiAccessToken();
       GHD_meta_values__mdt  ghdMetaData = GHD_meta_values__mdt.getInstance('GHDBaseURL');
        System.debug('##site:' +ghdMetaData.Value__c+'/dcc');
        req.setEndpoint(ghdMetaData.Value__c+'/dcc');
        req.setMethod('POST');
        req.setHeader('Authorization','bearer' + ' ' + accessTokenService.access_token);
     

        //String jsonRequestInput =   JSON.serialize(this.wrapper);
        System.debug('jsonRequestInput:'+jsonBody);
        req.setBody(jsonBody);
        HttpResponse response = http.send(req);
        System.debug('#response1:'+response.getBody());
       return response.getBody();
    }
    
}