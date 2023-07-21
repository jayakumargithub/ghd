/**
 * Created by Jayakumar Mogenahall on 28/04/2023.
 */

public with sharing class CreateCustomerProcess {

    @InvocableMethod(Callout=true)
    public static  void createCustomer(List<Id> accountIds){

system.debug('accountIds:' +accountIds);
        Account acc = [SELECT Id,
                                        CustomerId__c,
                                        CommercialName__c,
                                        ShippingStreet,
                                        ShippingCity,
                                        ShippingState,
                                        ShippingCountry,
                                        ShippingPostalCode,
                                        BillingStreet,
                                        BillingCity,
                                        BillingState,
                                        BillingCountry,
                                        BillingPostalCode,
                                        Primary_Email__c,
                                        Phone,
                                        CountryCurrency__c,
                                        SalesSegment__c,
                                        Status__c,
                                        Etage__c,
                                        BlockStatus__c,
                                        CodePorte__c,
                                        TaxNumber__c,
                                        Origin__c,
                                        SalesTaxNumber__c,
                                        LocalCustomerId__c,
                                        FirstName__c,
                                        LastName__c
        FROM Account WHERE Id =: accountIds[0]];


        List<Origin__c> origins = [SELECT Id,eCommStore__c,CountryCode__c,Identifier__c,Application__c FROM Origin__c WHERE Id =: acc.Origin__c];
        List<AdditionalInfo__c> additionalInfos = [SELECT Id,Info5__c,Info4__c,Info3__c,Info2__c,Info1__c FROM AdditionalInfo__c WHERE Account__c =: acc.Id];

            CreateAccountWrapper  wrapper = new CreateAccountWrapper();
            wrapper.CreateCustomerRequest.localCustomerId = acc.LocalCustomerId__c;
            wrapper.CreateCustomerRequest.commercialName = acc.CommercialName__c;
            String shippingStreet1  = String.isNotBlank(acc?.ShippingStreet) && acc?.ShippingStreet.contains(',')  == true ? acc?.ShippingStreet.split(',')[0] : acc?.ShippingStreet;
            String shippingStreet2  = String.isNotBlank(acc?.ShippingStreet) && acc?.ShippingStreet.contains(',')  == true ? acc?.ShippingStreet.split(',')[1] : '';
            String deliveryStreet1  = String.isNotBlank(acc?.BillingStreet) && acc?.BillingStreet.contains(',')  == true ? acc?.BillingStreet.split(',')[0] : acc?.BillingStreet;
            String deliveryStreet2  = String.isNotBlank(acc?.BillingStreet) && acc?.BillingStreet.contains(',')  == true ? acc?.BillingStreet.split(',')[1] : '';
            wrapper.CreateCustomerRequest.deliveryAddressLine1 = shippingStreet1;
            wrapper.CreateCustomerRequest.deliveryAddressLine2 = string.isNotBlank(shippingStreet2) ? shippingStreet2 :'';
            wrapper.CreateCustomerRequest.deliveryTown = acc?.ShippingCity;
            wrapper.CreateCustomerRequest.deliveryCountryCode = acc?.ShippingCountry;
            wrapper.CreateCustomerRequest.deliveryPostcode = acc?.ShippingPostalCode;
            wrapper.CreateCustomerRequest.invoiceAddressLine1 = deliveryStreet1;
            wrapper.CreateCustomerRequest.invoiceAddressLine2 = String.isNotBlank(deliveryStreet2)  ? deliveryStreet2 : '';
            wrapper.CreateCustomerRequest.invoiceTown = acc.BillingCity;
            wrapper.CreateCustomerRequest.invoiceCountryCode =  acc?.BillingCountry;
            wrapper.CreateCustomerRequest.invoicePostcode = acc?.BillingPostalCode;
            wrapper.CreateCustomerRequest.emailAddress = acc?.Primary_Email__c;
            wrapper.CreateCustomerRequest.telephoneNumber = acc?.Phone;
            wrapper.CreateCustomerRequest.countryCurrency = acc?.CountryCurrency__c;
            wrapper.CreateCustomerRequest.SalesSegment  = acc?.SalesSegment__c;
            wrapper.CreateCustomerRequest.taxNumber = acc.TaxNumber__c;
            wrapper.CreateCustomerRequest.SalesTaxNumber = acc.SalesTaxNumber__c;
            wrapper.CreateCustomerRequest.accountStatus = 'New customer';
            wrapper.CreateCustomerRequest.blockStatus = 'b';
            wrapper.CreateCustomerRequest.etage = acc.Etage__c;
            wrapper.CreateCustomerRequest.codePorte = acc.CodePorte__c;
            wrapper.CreateCustomerRequest.customerName =  acc.FirstName__c + ' ' + acc.LastName__c;
            OriginModel oModel = new OriginModel();
            Boolean isOriginExits = origins?.size() > 0;
            oModel.originIdentifier = isOriginExits ? origins[0]?.Identifier__c: '';
            oModel.originApplication =  isOriginExits ? origins[0]?.Application__c:'';
            oModel.countryCode = isOriginExits ? origins[0]?.CountryCode__c:'';
            oModel.eCommStore = isOriginExits? origins[0]?.eCommStore__c:'';
            wrapper.CreateCustomerRequest.origin = oModel;

            AdditionalInfoModel model = new AdditionalInfoModel();
            model.info1 = additionalInfos.size() != 0 ? additionalInfos[0]?.Info1__c:'';
            model.info2 = additionalInfos.size() != 0 ? additionalInfos[0]?.Info2__c:'';
            model.info3 = additionalInfos.size() != 0 ? additionalInfos[0]?.Info3__c:'';
            model.info4 = additionalInfos.size() != 0 ? additionalInfos[0]?.Info4__c:'';
            model.info5 = additionalInfos.size() != 0 ? additionalInfos[0]?.Info5__c:'';
            wrapper.CreateCustomerRequest.additionalInfo = model;

        Map<String, Object> objMap = new Map<String, Object>{
            'additionalInfo' => wrapper.CreateCustomerRequest.additionalInfo,
            'origin' => wrapper.CreateCustomerRequest.origin,    
            'customerName' => wrapper.CreateCustomerRequest.customerName,
            'codePorte' => wrapper.CreateCustomerRequest.codePorte,
            'etage' => wrapper.CreateCustomerRequest.etage,
            'blockStatus' => wrapper.CreateCustomerRequest.blockStatus,
            'accountStatus' => wrapper.CreateCustomerRequest.accountStatus,
            'SalesTaxNumber' => wrapper.CreateCustomerRequest.SalesTaxNumber,
            'taxNumber' => wrapper.CreateCustomerRequest.taxNumber,
            'SalesSegment' => wrapper.CreateCustomerRequest.SalesSegment,
            'currency' => wrapper.CreateCustomerRequest.countryCurrency,
            'telephoneNumber' => wrapper.CreateCustomerRequest.telephoneNumber,
            'emailAddress' => wrapper.CreateCustomerRequest.emailAddress,
            'invoicePostcode' => wrapper.CreateCustomerRequest.invoicePostcode,
            'invoiceCountryCode' => wrapper.CreateCustomerRequest.invoiceCountryCode,
            'invoiceTown' => wrapper.CreateCustomerRequest.invoiceTown,
            'invoiceAddressLine2' => wrapper.CreateCustomerRequest.invoiceAddressLine2,
            'invoiceAddressLine1' => wrapper.CreateCustomerRequest.invoiceAddressLine1,
            'deliveryPostcode' => wrapper.CreateCustomerRequest.deliveryPostcode,
            'deliveryCountryCode' => wrapper.CreateCustomerRequest.deliveryCountryCode,
            'deliveryTown' => wrapper.CreateCustomerRequest.deliveryTown,
            'deliveryAddressLine2' => wrapper.CreateCustomerRequest.deliveryAddressLine2,
            'deliveryAddressLine1' => wrapper.CreateCustomerRequest.deliveryAddressLine1,
            'commercialName' => wrapper.CreateCustomerRequest.commercialName,    
            'Localcustomerid' => wrapper.CreateCustomerRequest.localCustomerId
            };
         
        HttpRequest req = new HttpRequest();
        GhdApiAccessTokenRequestService.AccessTokenWrapper accessTokenService = GhdApiAccessTokenRequestService.getGhdApiAccessToken();
        GHD_meta_values__mdt  ghdMetaData = GHD_meta_values__mdt.getInstance('GHDBaseURL');
        System.debug('##site:' +ghdMetaData.Value__c+'/cct');
        req.setEndpoint(ghdMetaData.Value__c+'/cct');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'bearer ' + accessTokenService.access_token);
        //String jsonBody = JSON.serialize(wrapper);
        String jsonBody = '{"CreateCustomerRequest":' + JSON.serialize(objMap) + '}';
        req.setBody(jsonBody);
        System.debug('#jsonBody:'+jsonBody);

        Http http = new Http();
        req.setTimeout(120000);
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            System.debug('##body:' + response.getBody());
            acc.MSD_Status__c ='Saved in MSD';
            update acc;
        }else{
            try{
            System.debug('#Error CreateCustomer :'+response.getStatusCode() );
            System.debug('##body:' + response.getBody());
            Map<String,Object> errorMap = new Map<String,Object>();
            Map<String,Object> errorMessageMap = new Map<String,Object>();
            errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            errorMessageMap = (Map<String,Object>) errorMap.get('error');
            
            acc.MSD_Status__c ='Error';
            acc.MSD_Error_Message__c = (String) errorMessageMap.get('errorText');
            update acc;
            
            }catch(Exception e){
              System.debug('Error in Error Message save');
            }
        }

    }

    public class CreateAccountWrapper{
        CreateAccountWrapper(){
            CreateCustomerRequest = new CreateCustomerRequest();
        }
        public CreateCustomerRequest CreateCustomerRequest;
    }
    class CreateCustomerRequest{
        public String Localcustomerid;
        public String customerName;
        public String commercialName;
        public String deliveryAddressLine1;
        public String deliveryAddressLine2;
        public String deliveryCountryCode;
        public String deliveryTown;
        public String deliveryPostcode;
        public String invoiceAddressLine1;
        public String invoiceAddressLine2;
        public String invoiceCountryCode;
        public String invoiceTown;
        public String invoicePostcode;
        public String emailAddress;
        public String telephoneNumber;
        public String countryCurrency;
        public String SalesSegment;
        public String taxNumber;
        public String SalesTaxNumber;
        public String accountStatus;
        public String blockStatus;
        public String etage;
        public String codePorte;
        public AdditionalInfoModel additionalInfo;
        public OriginModel origin;
    }
}