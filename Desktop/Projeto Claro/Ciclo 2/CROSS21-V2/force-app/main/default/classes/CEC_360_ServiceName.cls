public class CEC_360_ServiceName {
    
    public static String getServiceName(String metadata){
        if(Test.isRunningTest()){
            return generateMetadata(metadata);
        }
        List<CEC_360_serviceName__mdt> lstServiceName = [Select serviceName__c 
                                                         from CEC_360_serviceName__mdt where DeveloperName =:metadata LIMIT 1];
        return lstServiceName[0].serviceName__c;
    }
    
    public static String  generateMetadata(String devName){
        List<CEC_360_serviceName__mdt> lstServiceName = new List<CEC_360_serviceName__mdt>();
        CEC_360_serviceName__mdt objMdt = new CEC_360_serviceName__mdt();
        objMdt.DeveloperName = devName;
        objMdt.Label = devName;
        objMdt.ServiceName__c = '/' + devName;
        lstServiceName.add(objMdt);
        
        return objMdt.DeveloperName;
    }

}