public class SOLAR_IntegrationMessageDAO {
    public class IntegrationMessageDAOException extends Exception{}
    
    private static final String STD_MESSAGE_CODE = 'STD-MESSAGE';
    public static final String STD_MESSAGE = 'Sua solicitação não foi executada, tente novamente, ou abra um chamado informando o código: {!messageCode}';
    
    private String serviceName;
    private List<SOLAR_IntegrationMessage__mdt> listIntegrationMessages;
    private Map<Integer, SOLAR_IntegrationMessage__mdt> mapStatusCodeIntegMessages;
    
    public SOLAR_IntegrationMessageDAO(String serviceName){
        if(String.isBlank(serviceName)){
            throw new IntegrationMessageDAOException('Requered parameter not found: ' + serviceName);
        }
        this.serviceName = serviceName;
    }
    
    public void doSelect(){
        listIntegrationMessages = [SELECT MasterLabel 
                                        , IntegrationStatusCode__c
                                        , ReturnMessage__c 
                                     FROM Solar_IntegrationMessage__mdt
                                    WHERE ServiceParameter__c = :serviceName];
        
        mapStatusCodeIntegMessages = new Map<Integer, SOLAR_IntegrationMessage__mdt>();
        for(SOLAR_IntegrationMessage__mdt integrationMessage : listIntegrationMessages){
            mapStatusCodeIntegMessages.put(Integer.valueOf(integrationMessage.IntegrationStatusCode__c), integrationMessage);
        }
    }
    public String getCodeMessageByStatusCode(Integer integrationStatusCode){
        if(mapStatusCodeIntegMessages.containsKey(integrationStatusCode)){
            return mapStatusCodeIntegMessages.get(integrationStatusCode).MasterLabel;
        } else {
            return STD_MESSAGE_CODE;
        }
    }
}