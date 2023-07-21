public class RoyalMail {
    
    private static List<RoyalMail__c> rangeCache;
    
    public static Boolean doesCaseNeedTracking(Case inputCase) {
        return (
            	//inputCase.CaseMarket__c == 'UK' && 
            	(
                    inputCase.Status == 'RMA Assigned' || 
                    inputCase.Status == 'New'
                ) &&
           		(
                    inputCase.Origin == 'Email' ||  
                    inputCase.Origin == 'Phone' || 
                    inputCase.Origin == 'Chat' || 
                    inputCase.Origin == 'Social'
                ) &&
           		inputCase.Replacement_Sent__c == 'No' && 
                (
                    inputCase.Type == 'Complaint' || 
                    inputCase.Type == 'Standard Return'
                )
		);
    }
    
    public static void assignTrackingToCase(Case inputCase) {
        if(rangeCache == null) {
            rangeCache = RoyalMail__c.getall().values();
        }
        RoyalMail__c rangeSetToUse;
        for(RoyalMail__c rangeSet : rangeCache) {
            if(rangeSet.NextRangeNumber__c == null) {
                rangeSet.NextRangeNumber__c = rangeSet.StartRange1D__c;
            }
            // Check if there are any numbers left in the range
            if(rangeSet.NextRangeNumber__c <= rangeSet.EndRange1D__c) {
                // Assign the found tracking number to the case
                String nextRangeNumber = rangeSet.NextRangeNumber__c.format().remove(',').remove('.');
                inputCase.RoyalMail1DTrackingNumber__c = 
                    rangeSet.Prefix1D__c + 
                    nextRangeNumber + 
                    RoyalMail.calculateCheckDigit(nextRangeNumber, 'mod11') + 
                    rangeSet.OriginCode1D__c;
                
                // Increase the next range by one
                rangeSet.NextRangeNumber__c = rangeSet.NextRangeNumber__c + 1;
                
                // Calculate the unique identifier check digit
                inputCase.RoyalMail2DUniqueIdentifierCheck__c = RoyalMail.calculateCheckDigit(inputCase.RoyalMail2DUniqueIdentifier__c, 'luhn16');
                
                return;
            }
        }
        // Did not find any ranges that could been used
        throw new RoyalMailException('No Royal Mail tracking numbers found');
    }
    
    public static void updateRangeChanges() {
        if(rangeCache != null) {
            update rangeCache;
        }
    }
    
    public static String calculateCheckDigit(String input, String method) {
        switch on method {
            when 'mod11' {
                return calculateMod11(input);
            }
            when 'luhn16' {
                return caluclateLuhn16(input);
            }
            when else {
                throw new RoyalMailException('Could not find check digit method for \'' + method + '\'');
            }
        }
    }
    
    private static String calculateMod11(String input) {
        String checkDigit;
        List<Integer> weight = new List<Integer>{8,6,4,2,3,5,9,7};
        Integer totalWeight = 0;
        Integer digitPos = 0;
        for(String digit : input.split('')) {
        	totalWeight += Integer.valueOf(digit) * weight.get(digitPos);
            digitPos++;
        }
        checkDigit = String.valueOf(11 - (Math.mod(totalWeight, 11)));
        if(checkDigit == '10') {
            checkDigit = '0';
        } else if(checkDigit == '11') {
            checkDigit = '5';
        }
        if(checkDigit == null) {
            throw new RoyalMailException('Could not calculate mod11 check digit for \'' + input + '\'');
        }
        return checkDigit;
    }
    private static STring caluclateLuhn16(String input) {
        String checkDigit;
        Map<String, Integer> weightMap = new Map<String, Integer>();
        weightMap.put('0', 0);
        weightMap.put('1', 1);
        weightMap.put('2', 2);
        weightMap.put('3', 3);
        weightMap.put('4', 4);
        weightMap.put('5', 5);
        weightMap.put('6', 6);
        weightMap.put('7', 7);
        weightMap.put('8', 8);
        weightMap.put('9', 9);
        weightMap.put('A', 10);
        weightMap.put('B', 11);
        weightMap.put('C', 12);
        weightMap.put('D', 13);
        weightMap.put('E', 14);
        weightMap.put('F', 15);
        
        Map<Integer, String> hexMap = new Map<Integer, String>();
        hexMap.put(0, '0');
        hexMap.put(1, '1');
        hexMap.put(2, '2');
        hexMap.put(3, '3');
        hexMap.put(4, '4');
        hexMap.put(5, '5');
        hexMap.put(6, '6');
        hexMap.put(7, '7');
        hexMap.put(8, '8');
        hexMap.put(9, '9');
        hexMap.put(10, 'A');
        hexMap.put(11, 'B');
        hexMap.put(12, 'C');
        hexMap.put(13, 'D');
        hexMap.put(14, 'E');
        hexMap.put(15, 'F');
        
        Integer totalWeight = 0;
        List<String> digitList = input.split('');
        List<String> reverseDigitList = new List<String>();
        for(Integer i = digitList.size() - 1; i >= 0; i--){
            reverseDigitList.add(digitList.get(i));
        }
        for(Integer i = 0; i < reverseDigitList.size(); i=i+2){
            Integer digitWeight = weightMap.get(reverseDigitList.get(i));
            Integer doubleDigitWeight = digitWeight * 2;
            if(doubleDigitWeight >= 10 && doubleDigitWeight <= 15) {
                totalWeight += digitWeight;
            } else if(doubleDigitWeight >= 16) {
                doubleDigitWeight -= 6;
                List<String> digitSplit;
                do {
                	digitSplit = String.valueOf(doubleDigitWeight).split('');
                    doubleDigitWeight = Integer.valueOf(digitSplit.get(0)) + Integer.valueOf(digitSplit.get(1));
                } while(doubleDigitWeight > 10);
                totalWeight += doubleDigitWeight;
            } else {
                totalWeight += doubleDigitWeight;
            }
        }
        for(Integer i = 1; i < reverseDigitList.size(); i=i+2){
            Integer digitWeight = weightMap.get(reverseDigitList.get(i));
            totalWeight += digitWeight;
        }
        Integer nextMultiple = 16 * Integer.valueOf(Math.ceil(Decimal.valueOf(totalWeight) / 16));
        String returnDigit = hexMap.get(nextMultiple - totalWeight);
        if(returnDigit == null) {
            throw new RoyalMailException('Could not calculate luhn16 check digit for \'' + input + '\'');
        }
        return returnDigit;
    }
}