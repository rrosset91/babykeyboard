public class HierarchyLimitWrapper {
    @AuraEnabled
    public String codigoRetorno {get;set;}
    @AuraEnabled
    public String mensagemRetorno {get;set;}
    @AuraEnabled
    public Boolean autorizado {get;set;}
    @AuraEnabled
	public String hashAutoridade {get;set;}
	
	public HierarchyLimitWrapper(){
		this.autorizado = false;
	}

}