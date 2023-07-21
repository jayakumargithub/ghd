@isTest(SeeAllData = true)
private class WarrantyOnlineReturnWebServiceTest {

    @isTest
    static void test_method_one() {
        Test.startTest();
        buildData();
        //sendTest('dsvbfdgnbgfvda', '22334455', 'Stopped operating', 'Mini Comb', 'Combs', 'Combs', 'WRp10196016', 'Sula', 'Millar', '07377364713', 'consultant@artofcloud.co.uk', '', 'Bradford', 'west yorkshire', '', '', '97 Hastings Avenue', 'GB', 'GB', 'ghd-uk', 'CCV2', 'p1','','');
        sendTest('dsvbfdgnbgfvda', '22334455', 'Stopped operating', 'Mini Comb', 'Combs', 'Combs', 'WRp10196016', 'Josh' , 'Tonks','07777123123','josh@artofcloud.co.uk');
        sendTest('dsvbfdgnbgfvda', '9862956256', 'Stopped operating', 'Mini Comb', 'Combs', 'Combs', 'WRp10196016', 'Test' , 'Test','07777123123','test@artofcloud.co.uk');

        Test.stopTest();
    }
    static void sendTest(String courierID, String dateCode, String problem, String productName, String productType, String returningType, String trackingNumber, String firstName, String lastName, String mobile, String email) {

   // static void sendTest(String courierID, String dateCode, String problem, String productName, String productType, String returningType, String trackingNumber, String firstName, String lastName, String mobile, String email, String title, String townCity, String county, String address_3, String address_2, String address_1, String country, String countryCode, String eCommStore, String originApplication, String originIdentifier, String additional_1, String additional_2) {
        WarrantyOnlineReturnWrap parent = new WarrantyOnlineReturnWrap();
        WarrantyOnlineReturnWrap.customer customer = new WarrantyOnlineReturnWrap.customer();

        parent.courierID = courierID;
        parent.dateCode = dateCode;
        parent.problem = problem;
        parent.productName = productName;
        parent.productType = productType;
        parent.returningCustomer = returningType;
        parent.trackingNumber = trackingNumber;
        
        customer.mobile = mobile;
        customer.email = email;
        customer.firstName = firstName;
        customer.lastName = lastName;

        /*//parent.customer.dob = dob;
        parent.customer.title = title;
        parent.customer.townCity = townCity;
        parent.customer.county = county;
        parent.customer.address_3 = address_3;
        parent.customer.address_2 = address_2;
        parent.customer.address_1 = address_1;
        parent.customer.additional_2 = additional_2;
        parent.customer.additional_1 = additional_1;
        parent.customer.country = country;

        parent.origin.countryCode = countryCode;
        parent.origin.eCommStore = eCommStore;
        parent.origin.originApplication = originApplication;
        parent.origin.originIdentifier = originIdentifier;
        */
        //parent.returningCustomer = parent;
        String jSon = JSON.serialize(parent);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/warrantyOnlineReturn';
        req.requestBody = Blob.valueOf(jSon);
        RestContext.request = req;
        RestContext.response = res;

        WarrantyOnlineReturnWebService.warrantyOnlineReturn();

        String returnBlob = String.valueOf(res.responseBody);
    }
    
    @isTest static void buildData() {
		Account account = new Account();
		account.Name = 'Josh Tonks Ltd';
		account.CurrencyIsoCode = 'GBP';
		account.BillingStreet = 'tbc';
		account.BillingCity = 'tbc';
		account.BillingPostalCode = 'tbc';
		account.BillingCountry = 'tbc';

		insert account;

		Contact contact = new Contact();
        contact.FirstName = 'Josh';
		contact.LastName = 'Tonks';
        contact.MobilePhone = '07777123123';
		contact.Account = account;
		contact.Email = 'josh@artofcloud.co.uk';
		contact.AccountId = account.Id;

		insert contact;
    }
}