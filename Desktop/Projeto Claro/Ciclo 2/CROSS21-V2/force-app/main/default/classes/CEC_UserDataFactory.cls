/*
* Author: Renan S. de Freitas - Squad visão 360 
* Company: Deloitte Brasil 
* Date: 28/01/2020 
* Description: Datafactory do objeto User, com o objetivo de criar massa de dados para testes
* 
*
* ---------------------------------------------------------------
*/
@isTest
public with sharing class CEC_UserDataFactory
{
    public static User createUserWithProfileCriticalChannels()
    {
        Profile profileCriticalChannels = [SELECT id FROM Profile WHERE Name = 'Representantes Canais Criticos'];
        
        User userCriticalChannels = new User();
        userCriticalChannels.FirstName = 'Critical chanel';
        userCriticalChannels.LastName = 'By Name';        
        userCriticalChannels.ProfileId = profileCriticalChannels.id;
        userCriticalChannels.CommunityNickname = 'sadminofdojo';
        userCriticalChannels.Username = 'doje45@gmail.com' + System.currentTimeMillis();
        userCriticalChannels.TimeZoneSidKey = 'America/Los_Angeles';
        userCriticalChannels.EmailEncodingKey = 'UTF-8';
        userCriticalChannels.LanguageLocaleKey = 'en_US';
        userCriticalChannels.LocaleSidKey = 'en_US';
        userCriticalChannels.Title = 'Title';
        userCriticalChannels.Alias = 'Alias';
        userCriticalChannels.Email = 'doijejdjeoj23@0.teste.com.br';		     
        insert userCriticalChannels;
        
        return userCriticalChannels;
    }
    
     public static User createUserWithProfileGovSupervisor()
    {
        Profile profileGovSupervisor = [SELECT id FROM Profile WHERE Name = 'Supervisor Gov'];
        
        User userGovSupervisor = new User();
        userGovSupervisor.FirstName = 'Critical chanel';
        userGovSupervisor.LastName = 'By Name';        
        userGovSupervisor.ProfileId = profileGovSupervisor.id;
        userGovSupervisor.CommunityNickname = 'gov@0.teste.com.br';
        userGovSupervisor.Username = 'gov@0.teste.com.br' + System.currentTimeMillis();
        userGovSupervisor.TimeZoneSidKey = 'America/Los_Angeles';
        userGovSupervisor.EmailEncodingKey = 'UTF-8';
        userGovSupervisor.LanguageLocaleKey = 'en_US';
        userGovSupervisor.LocaleSidKey = 'en_US';
        userGovSupervisor.Title = 'Title';
        userGovSupervisor.Alias = 'Alias';
        userGovSupervisor.Email = 'gov@0.teste.com.br';
        insert userGovSupervisor;

        return userGovSupervisor;
    } 
}