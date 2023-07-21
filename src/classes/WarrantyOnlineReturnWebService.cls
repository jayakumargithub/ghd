@RestResource(urlMapping='/warrantyOnlineReturn')
/** 
* @param 
*/
global with sharing class WarrantyOnlineReturnWebService {
    @HttpPost
    global static ReturnWrapper warrantyOnlineReturn()
    {
        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        WarrantyOnlineReturnWrap warrantyOnlineReturn;
        List <Account> acc = new List <Account>();
        Contact con = new Contact();
        List <Material__c> prod = new List <Material__c>();
        List <Origin__c> origi = new List <Origin__c>();
        List <Case> case1 = new List <Case>();
        Origin__c ori = new Origin__c();
        List <OrderLineItem__c> OLI = new List <OrderLineItem__c>();
        Contact coni = new Contact();
        Case cse = new Case();
        String Message;
        String ContactId;
        ReturnWrapper returnWrapper;

            warrantyOnlineReturn = WarrantyOnlineReturnWrap.parse(req.requestBody.toString());
            system.debug(warrantyOnlineReturn);
            OLI = [SELECT Id, Material__c FROM OrderLineItem__c WHERE DateCode__c = :warrantyOnlineReturn.dateCode LIMIT 1];
            system.debug(OLI);
            //origi = [SELECT Id, Application__c, eCommStore__c, Identifier__c, CountryCode__c FROM Origin__c WHERE Identifier__c = :warrantyOnlineReturn.origin.originIdentifier LIMIT 1];
            //acc = [SELECT Id FROM Account WHERE Origin__c = :origi[0].Id LIMIT 1];
            try{
            con = [SELECT Id, AccountId, FirstName,LastName,Email,Phone FROM Contact WHERE Email = :warrantyOnlineReturn.customer.email AND LastName = :warrantyOnlineReturn.customer.lastName LIMIT 1];
            } catch(Exception e){
                
                System.debug('No Contact');
            }

            if (con != null){
                ContactId = con.Id;
            }else {
                
                coni.firstName = warrantyOnlineReturn.customer.firstName;
                coni.lastName = warrantyOnlineReturn.customer.lastName;
                if (acc[0].Id != '') {
                coni.AccountId = acc[0].Id;
                }
                coni.Phone = warrantyOnlineReturn.customer.mobile;
                coni.Email = warrantyOnlineReturn.customer.email;
                coni.MailingStreet = warrantyOnlineReturn.customer.address_1 /* + '' + warrantyOnlineReturn.customer.address_2 + '' + warrantyOnlineReturn.customer.address_3} */;
                coni.MailingCity = warrantyOnlineReturn.customer.townCity;
                coni.MailingState = warrantyOnlineReturn.customer.county;
                coni.MailingPostalcode = warrantyOnlineReturn.customer.postcode;
                coni.MailingCountry = warrantyOnlineReturn.customer.country;
                coni.Title = warrantyOnlineReturn.customer.title;

                insert coni;

                con = [SELECT Id, AccountId, FirstName,LastName,Email,Phone FROM Contact WHERE Email = :warrantyOnlineReturn.customer.email AND LastName = :warrantyOnlineReturn.customer.lastName LIMIT 1];
                ContactId = con.Id;
            }
            
            //prod = [SELECT Id FROM ghdProuct__c WHERE Name = :warrantyOnlineReturn.productName LIMIT 1];
            
            
            if (warrantyOnlineReturn.dateCode == ''){
                Message = Message + 'dateCode is blank ,';
            }
            if (warrantyOnlineReturn.productName == ''){
                Message = Message + 'productName is blank ,';
            }
            if (warrantyOnlineReturn.productType == ''){
                Message = Message + 'productType is blank ,';
            }
            if (warrantyOnlineReturn.returningCustomer == ''){
                Message = Message + 'returningCustomer is blank ,';
            }
            if (warrantyOnlineReturn.problem == ''){
                Message = Message + 'problem is blank ,';
            }
    
            //cse.AccountId = Acc[0].Id;
            cse.ContactId = con.Id;
            cse.Material__c = OLI[0].Material__c;
            if (warrantyOnlineReturn.problem != '') {
            //cse.Issue_with_Product__c = warrantyOnlineReturn.problem;
            }
            if (warrantyOnlineReturn.courierId != '') {
            cse.Courier_Code__c = warrantyOnlineReturn.courierId;
            }
            if (warrantyOnlineReturn.productType != '') {
            cse.Type_of_Product__c = warrantyOnlineReturn.productType;
            }
            cse.Origin = 'Web';
            cse.Type = 'Warranty Returns';
            //cse.Date_Code__c = warrantyOnlineReturn.dateCode;
            insert cse;

            case1 = [SELECT Id, CaseNumber, AccountId, ContactId, /*Issue_with_Product__c,*/ Courier_Code__c, Product_Name__c,Product_New__c, Type_of_Product__c, origin, Purchase_Date__c FROM Case WHERE Id = :cse.Id LIMIT 1];

            /*
            ori.Application__c = warrantyOnlineReturn.origin.originApplication;
            ori.eCommStore__c = warrantyOnlineReturn.origin.eCommStore;
            ori.Identifier__c = warrantyOnlineReturn.origin.originIdentifier;
            ori.CountryCode__c = warrantyOnlineReturn.origin.countryCode;

            insert ori;
            */


        returnWrapper = setValues(case1[0], con, /*origi[0],*/ Message);
        return returnWrapper;
    }
    public static ReturnWrapper setValues(Case case1, Contact con, /*Origin__c origi,*/ String Message){
        ReturnWrapper ret = new ReturnWrapper();
        ret.CaseNo = case1.CaseNumber;
        ret.Contact = case1.ContactId;
        ret.firstName = con.firstName;
        ret.lastName = con.lastName;
        ret.phone = con.phone;
        ret.email = con.email;
        ret.product = case1.Product_New__c;
        /*
        ret.Application = origi.Application__c;
        ret.eCommStore = origi.eCommStore__c;
        ret.Identifier = origi.Identifier__c;
        ret.CountryCode = origi.CountryCode__c;
        */
        ret.Message = Message;
        return ret;
    }

    global class returnWrapper{
        public String Message {get; set;}
        public String CaseNo {get; set;}
        public String Contact {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String phone {get; set;}
        public String email {get; set;}
        public String product {get; set;}
        /*
        public String Application {get; set;}
        public String eCommStore {get; set;}
        public String Identifier {get; set;}
        public String CountryCode {get; set;}
        */
        public ReturnWrapper(){}
    }
}