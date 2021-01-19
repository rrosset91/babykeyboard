global class CEC_IntegrationGeographicLocation {
    
    private ServiceParameter__c parameter = new ServiceParameter__c();
    
    private HttpRequest request;
    
    public CEC_IntegrationGeographicLocation() {
        this.parameter = ServiceParameter__c.getInstance('GeoLocationNew');       
    }
    
    global CEC_IntegrationGeoLocationDTO consultar(List<String> args){
        CEC_IntegrationGeoLocationDTO lRes = new CEC_IntegrationGeoLocationDTO();
        try{
            String params = '?' + String.join(args, '&');
            String lBodyRes = JSON.serialize(new CEC_IntegrationGeoLocationDTO());
            String lHttpRes = '-1';      
            createRequest(params);  
            HTTPResponse response =  CEC_HttpReq.sendReq(this.request, null);
            lBodyRes = response.getBody();
            map<String, String> lMapResWord = new map<String, String>{ '" :' => '":',
                '"type":' => '"typeZ":', '"number":' => '"numberZ":' };
                    for (String iJsonAttr: lMapResWord.keyset()){
                        lBodyRes = lBodyRes.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
                    }
            if(String.isNotBlank(lBodyRes)) {
                lHttpRes = String.valueOf(response.getStatusCode());
                Object lObj = JSON.deserialize(lBodyRes, CEC_IntegrationGeoLocationDTO.class);
                lRes = (CEC_IntegrationGeoLocationDTO)lObj;
                system.debug('RESPONSE geographicLocation novo::'+response.getBody());
            }
        }catch(Exception e){
            throw e;
        }
        return lRes;
    }
    
    private void createRequest(string params){
        this.request = new HttpRequest();
        string usuario;
        string senha;
        usuario = this.parameter.User__c;
        senha = this.parameter.Password__c;
        system.debug(this.parameter.EndPoint__c);
        request.setEndpoint(this.parameter.EndPoint__c + params); 
        request.setMethod(this.parameter.Method__c);
        request.setTimeout(Integer.valueOf(this.parameter.Timeout__c)); 
        String sAuth = CEC_IntegrationHelper.getBasicAuth(
            new String[]{ usuario, senha });
        request.setHeader('Authorization', sAuth); 
    }
    
}