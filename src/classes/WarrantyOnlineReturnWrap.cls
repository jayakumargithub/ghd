public class WarrantyOnlineReturnWrap {

        public Customer customer;
        public Origin origin;
        public String dateCode;
        public String productName;
        public String productType;
        public String returningCustomer;
        public String problem;
        public String courierID;
        public String trackingNumber;
    
        public class customer {
            public String title;
            public String firstName;
            public String lastName;
            public String email;
            public String mobile;
            public Date dob;
            public String address_1;
            public String address_2;
            public String address_3;
            public String townCity;
            public String country;
            public String county;
            public String postcode;
            public String additional_1;
            public String additional_2;
        }
    
        public class origin {
            public String originApplication;
            public String originIdentifier;
            public String countryCode;
            public String eCommStore;
        }
    
        public static WarrantyOnlineReturnWrap parse(String json) {
            return (WarrantyOnlineReturnWrap) System.JSON.deserialize(json, WarrantyOnlineReturnWrap.class);
        }
}