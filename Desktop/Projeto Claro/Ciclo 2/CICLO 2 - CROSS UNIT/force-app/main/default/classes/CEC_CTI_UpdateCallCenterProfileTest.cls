/*
* Autor: Diego Lima - Deloitte
* Data: 05/07/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 7] + [Classe utilizada para os testes da classe
* CEC_CTI_GetListProfileMetadata]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 05/07/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação da classe e dos métodos updateUserCallCenterSuccess, updateUserCallCenterError]
*-----------------------------------------------------------------
* Data: 09/12/2019
* Autor: Diego Lima - Deloitte
* Alterações: retirada a dependencia da classe TestSetup]
*
*
*/

@isTest
public class CEC_CTI_UpdateCallCenterProfileTest {

    @isTest
    static void updateUserCallCenterSuccess(){
        
        List <User> listaUsuario = new List <User>();
        
        //User userTest = CEC_CTI_TestSetup.getNewUser();
        
        User lUser = new User();
        lUser.firstName = 'test1';
        lUser.lastName = 'test1';
        lUser.Alias = 'alias1';
        lUser.Email = 'teste1@claro.com.br';
        lUser.Username = 'teste1@claro.com.br';
        lUser.Profileid = userinfo.getProfileId();
        lUser.LanguageLocaleKey = 'pt_BR';
        lUser.EmailEncodingKey = 'ISO-8859-1';
        lUser.LocaleSidKey = 'pt_BR';
        lUser.TimeZoneSidKey = 'America/Sao_Paulo';
        lUser.IsActive = true;
        lUser.CommunityNickname = lUser.lastName;
        
        insert lUser;
        
        listaUsuario.add(lUser);
        
        String callCenter = CEC_CTI_UpdateCallCenterProfile.updateProfile(listaUsuario);
        System.assertEquals('CallCenter Inserido ou Atualizado.', callCenter);
        
    }
    
    @isTest
    static void updateUserCallCenterError(){
        
        List <User> listaUsuario = new List <User>();
        
        //User userTest = CEC_CTI_TestSetup.getUserAdminClaro();
        
        ProfileCallCenter__mdt profileMdt = [SELECT Id, MasterLabel FROM ProfileCallCenter__mdt LIMIT 1];
        
        Profile profileId = [SELECT Id, Name FROM Profile WHERE Name =: profileMdt.MasterLabel LIMIT 1];
        
        User lUser = new User();
        lUser.firstName = 'test1';
        lUser.lastName = 'test1';
        lUser.Alias = 'alias1';
        lUser.Email = 'teste1@claro.com.br';
        lUser.Username = 'teste1@claro.com.br';
        lUser.Profileid = profileId.Id;
        lUser.LanguageLocaleKey = 'pt_BR';
        lUser.EmailEncodingKey = 'ISO-8859-1';
        lUser.LocaleSidKey = 'pt_BR';
        lUser.TimeZoneSidKey = 'America/Sao_Paulo';
        lUser.IsActive = true;
        lUser.CommunityNickname = lUser.lastName;
        
        insert lUser;
        
        listaUsuario.add(lUser);
        
        String callCenter = CEC_CTI_UpdateCallCenterProfile.updateProfile(listaUsuario);
        System.assertEquals('Nenhum CallCenter Atribuído.', callCenter);
        
    }
}