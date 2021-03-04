@isTest
public class CEC_SSO_SessionsPolicyTest {
    
    public static testMethod void testMethodEvaluate(){
        
        System.Test.startTest() ;
        
        Multisessao__mdt multisessao = [SELECT MasterLabel FROM Multisessao__mdt Limit 1];
        system.debug('multisessao>>' + multisessao);
        String profile = multisessao.MasterLabel;
        //String profile = 'Suporte';
        system.debug('profile>>' + profile);             
        //Profile uProfile = [SELECT Id FROM Profile WHERE name = :profile];
        //system.debug('uProfile>>' + uProfile);
        //User uEvent = New User();
        //uEvent = [Select Id from User where IsActive = true AND LastLoginDate != null and profileId = :uProfile.Id Limit 1];
        String idUsuarioAtual = userInfo.getUserId();
        LoginHistory lh = [ SELECT UserId FROM LoginHistory where UserId = : idUsuarioAtual  Limit 1];
        
        Map<String, String> eventData = new Map<String, String>();
        eventData.put('LoginHistoryId', lh.Id);
        
        
        TxnSecurity.Event e = new TxnSecurity.Event(
            UserInfo.getOrganizationId(),
            idUsuarioAtual, /* userId */
            'AuthSession', /* entityName */
            'Login', /* action */
            'LoginHistory', /* resourceType */
            //'01pR00000009D2H', /* entityId */
            lh.Id,
            Datetime.newInstance(2018, 11, 15), /* timeStamp */
            eventData); /* data - Map with info about this event. */
        
        CEC_SSO_SessionsPolicy condition = new CEC_SSO_SessionsPolicy();
        
        System.assertEquals(false, condition.evaluate(e));
        
    }
}