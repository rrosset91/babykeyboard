/*
* Autor: Diego Lima - Deloitte
* Data: 05/07/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 7] + [Classe utilizada para criar as regras 
* para inserção/alteração de CallCenter para o usuário]
* Controle de Versão
* ---------------------------------------------------------------
* Data: 05/07/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação da classe e do método updateProfile]
*----------------------------------------------------------------
* Data: 09/12/2019
* Autor: Diego Lima - Deloitte
* Alterações: Recompilação para versão 47]
*
*/

public with sharing class CEC_CTI_UpdateCallCenterProfile {
    
    public static String updateProfile(List<User> lstNewUser){
        
        Set<String> setNameProfile = new Set<String>();
        Set<String> setProfileId = new Set<String>();
        Set<String> setCallCenterName = new Set<String>();
        String resultReturned;

        for(User usuario : lstNewUser)
        {
            setProfileId.add(usuario.ProfileId);
        }
        
        List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id  IN: setProfileId]; 
        for(Profile perfil : lstProfile)
        {
            setNameProfile.add(perfil.name);
        }
        		
        List <ProfileCallCenter__mdt> lstMedatado = new List <ProfileCallCenter__mdt>();
        
        if(Test.isRunningTest()){
              
  				lstMedatado = CEC_CTI_GetListProfileMetadata.generateListMetadata();
                            
        } else {   
        
            lstMedatado = [SELECT MasterLabel, 
                           InternalName_CallCenter__c
                           FROM ProfileCallCenter__mdt 
                           WHERE MasterLabel IN : setNameProfile];
        }
                
        Map<String, String> mapProfileCallCenter = new Map<String, String>();
        for(ProfileCallCenter__mdt  callCenter : lstMedatado)
        {
            mapProfileCallCenter.put(callCenter.MasterLabel, callCenter.InternalName_CallCenter__c);
            setCallCenterName.add(callCenter.InternalName_CallCenter__c);
        }

        Map<Id, String> mapProfileNameById = new Map<Id, String>();
        List <Profile> listProfileName = [SELECT Id,
                                         Name
                                         FROM Profile
                                         WHERE Name IN : setNameProfile];
        
        for(Profile perfil : listProfileName){
            mapProfileNameById.put(perfil.Id, perfil.Name);
        }
   		
        Map<String, Id> mapCallCenter = new Map<String, Id>();
        List <CallCenter> callCenterID = [SELECT Id, Name FROM CallCenter WHERE Name IN : setCallCenterName];
        for(CallCenter forCallCenter : callCenterID){
            mapCallCenter.put(forCallCenter.Name, forCallCenter.Id);
        }

        
        for(User usuario : lstNewUser)
        {
            if(mapProfileCallCenter.containskey(mapProfileNameById.get(usuario.ProfileId))){
                usuario.CallCenterId = mapCallCenter.get(mapProfileCallCenter.get(mapProfileNameById.get(usuario.ProfileId)));
            	resultReturned = 'CallCenter Inserido ou Atualizado.';
            } else {
                usuario.CallCenterId = null;
                resultReturned = 'Nenhum CallCenter Atribuído.';
            }
        }
        
        return resultReturned;
    }

}