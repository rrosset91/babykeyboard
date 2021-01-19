public with sharing class CEC_CatalogUtilities {
    
    public static String getSandboxName(){
        String sandboxName = System.URL.getSalesforceBaseUrl().toExternalForm();
        sandboxName = sandboxName.substring(sandboxName.indexOf('--') + 2,sandboxName.indexOf('.my.'));
        return CEC_CatalogUtilities.isRunningInSandbox() ? sandboxName : 'production';
    }
    
    public static Boolean isRunningInSandbox() {
        String OrgId = UserInfo.getOrganizationId();
        return [Select isSandbox From Organization Where id = :OrgId].isSandbox;
    }  
    
    public static String generateKey(String currentDate, String SandboxName){
        return currentDate + SandboxName + getRandomKey();
    }
    
    public static String getRandomKey(){     
        Blob aesKey 			= Crypto.GenerateAESKey(128);
        String hexadecimalKey 	= EncodingUtil.ConvertTohex(aesKey);
        
        return hexadecimalKey.SubString(0,8)+ hexadecimalKey.SubString(8,12) + hexadecimalKey.SubString(12,16) + hexadecimalKey.SubString(16,20);
    }
    
    public static String getCurrentDate(){
        
        Date dtToday = Date.today();
        String strDay = String.valueOf(dtToday.day());
        String strMonth = String.valueOf(dtToday.month());
        String strYear = String.valueOf(dtToday.year());
                
        return strYear + strMonth.leftPad(2, '0') + strDay.leftPad(2, '0');
    }
}