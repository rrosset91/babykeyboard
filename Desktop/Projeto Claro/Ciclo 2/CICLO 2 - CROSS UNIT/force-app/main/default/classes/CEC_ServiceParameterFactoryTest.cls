@isTest
public class CEC_ServiceParameterFactoryTest {
    public class ServiceParameterFactoryTestException extends Exception {}
    
    public enum ServiceParameterNames {CEC_360_WorkOrder_GET, CEC_360_OrderRequest_GET, CEC_360_OrderConfiguration_GET}
    
    @isTest 
    public static void mainTest() {
        ServiceParameter__c newServiceParameter = 
            new CEC_ServiceParameterFactoryTest().getInstance(ServiceParameterNames.CEC_360_WorkOrder_GET);
        
        System.assert(newServiceParameter != null, 'Instância não retornada!');
    }
    
    public ServiceParameter__c getInstance(ServiceParameterNames serviceParameterName) {
        if(ServiceParameterNames.CEC_360_WorkOrder_GET == serviceParameterName) {
            return getCEC_360_WorkOrder_GET();
        } else if(ServiceParameterNames.CEC_360_OrderRequest_GET == serviceParameterName) {
            return getCEC_360_OrderRequest_GET();
        } else if(ServiceParameterNames.CEC_360_OrderConfiguration_GET == serviceParameterName) {
            return getCEC_360_OrderConfiguration_GET();
        }  else {
            throw new ServiceParameterFactoryTestException(serviceParameterName + ' não encontrado');
        }
    }
    
    private ServiceParameter__c getCEC_360_WorkOrder_GET() {
        ServiceParameter__c newServiceParameter = new ServiceParameter__c();
        newServiceParameter.Name = 'CEC_360_WorkOrder_GET';
        newServiceParameter.EndPoint__c = '/orders/workorder';
        newServiceParameter.Method__c = 'GET';
        newServiceParameter.IsActive__c = true;
        newServiceParameter.Timeout__c = 120000;
        return newServiceParameter;
    }
    
    private ServiceParameter__c getCEC_360_OrderRequest_GET() {
        ServiceParameter__c newServiceParameter = new ServiceParameter__c();
        newServiceParameter.Name = 'CEC_360_OrderRequest_GET';
        newServiceParameter.EndPoint__c = '/orders/request';
        newServiceParameter.Method__c = 'GET';
        newServiceParameter.IsActive__c = true;
        newServiceParameter.Timeout__c = 120000;
        return newServiceParameter;
    }
    
    private ServiceParameter__c getCEC_360_OrderConfiguration_GET() {
        ServiceParameter__c newServiceParameter = new ServiceParameter__c();
        newServiceParameter.Name = 'CEC_360_OrderConfiguration_GET';
        newServiceParameter.EndPoint__c = '/orders/workorder';
        newServiceParameter.Method__c = 'GET';
        newServiceParameter.IsActive__c = true;
        newServiceParameter.Timeout__c = 120000;
        return newServiceParameter;
    }
    
    
}