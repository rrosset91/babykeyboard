/*
* Autor: Diego Lima - Deloitte
* Data: 05/07/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 7] + [Classe utilizada para criar os registros 
* de metadados necessários para os testes da classe CEC_CTI_UpdateCallCenterProfile]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 05/07/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação da classe e dos registros de metadados do objeto ProfileCallCenter__mdt]
*/


public class CEC_CTI_GetListProfileMetadata {

    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 7] + [O método generateListMetadata 
    * gera uma lista com registros do objeto de Metadados ProfileCallCenter__mdt para que estes possam ser utilizados 
    * na classe de testes]
    */
    
    public static List<ProfileCallCenter__mdt> generateListMetadata(){
        
    	List <ProfileCallCenter__mdt> listaPerfil = new List <ProfileCallCenter__mdt>();
        
        ProfileCallCenter__mdt perfilCustom1 = new ProfileCallCenter__mdt();
        
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id=:profileId].Name;
        String callCenterName = [SELECT Id, Name FROM CallCenter LIMIT 1].Name;
        perfilCustom1.Label = profileName;
        perfilCustom1.MasterLabel = profileName;
        perfilCustom1.InternalName_CallCenter__c = callCenterName;
        
        listaPerfil.add(perfilCustom1);
        
        return listaPerfil;
    
    }
    
}