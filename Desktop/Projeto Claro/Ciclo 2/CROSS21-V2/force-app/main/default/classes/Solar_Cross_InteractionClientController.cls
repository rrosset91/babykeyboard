/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Contreller of Solar_Cross_InteractionClient component
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-12-08      Jean Sganzerla          class created 
* @version   1.1    2020-12-08      Lucas Soldi             Method ** created 
**************************************************************************************************************/
public class Solar_Cross_InteractionClientController {

    //método que recupera as interações armazenadas no Customer Interaction Topic e devolve para o componente exibir em forma de histórico de chat
    @AuraEnabled
    public static InteractionHistory getClientHistory(String aCaseId){      
        Map<String, String> lFooterIconMap = new Map<String, String>{'Sucesso' => 'utility:success', 'Insucesso' => 'utility:clear'};
        Map<String, String> lFooterVariantMap = new Map<String, String>{'Sucesso' => 'success', 'Insucesso' => 'error'};
        
        InteractionHistory lReturn = new InteractionHistory();

        List<vlocity_cmt__CustomerInteractionTopic__c > lTopicLst = [SELECT Id, SolarCross_Status__c, SolarCross_Channel__c,SolarCross_CallId__c, SolarCross_Author__c, Comments__c, Solar_Cross_Type__c, CreatedDate, CreatedBy.CommunityNickname 
                                                                  FROM vlocity_cmt__CustomerInteractionTopic__c
                                                                  WHERE RecordType.DeveloperName = 'InteractionTentative' AND vlocity_cmt__CaseId__c = :aCaseId ORDER BY CreatedDate DESC];
        
        Map<String, ListInteraction> mapListInteraction = new Map<String, ListInteraction>();
        for(vlocity_cmt__CustomerInteractionTopic__c lTopic :lTopicLst){
            Interaction lInteraction = new Interaction();
            lInteraction.lId = lTopic.Id;
            lInteraction.lStatus = lTopic.SolarCross_Status__c;
            lInteraction.lChannel = lTopic.SolarCross_Channel__c;
            lInteraction.lAuthor = lTopic.SolarCross_Author__c;
            lInteraction.lComments = lTopic.Comments__c;
            lInteraction.lCommentsManual = lTopic.Comments__c;
            lInteraction.lType = lTopic.Solar_Cross_Type__c;
            lInteraction.lFooterIcon = lFooterIconMap.get(lTopic.SolarCross_Status__c);
            lInteraction.lFooterVariant = lFooterVariantMap.get(lTopic.SolarCross_Status__c);
            lInteraction.lClaroLogin = lTopic.CreatedBy.CommunityNickname;
            lInteraction.lCallId = lTopic.SolarCross_CallId__c;
            lInteraction.lCreatedDate = lTopic.CreatedDate;

            if(mapListInteraction.get(String.valueOf(lInteraction.lCreatedDate.date())) != null){
                mapListInteraction.get(String.valueOf(lInteraction.lCreatedDate.date())).lInteractionsLst.add(lInteraction);
            }else{
                mapListInteraction.put(String.valueOf(lInteraction.lCreatedDate.date()),new ListInteraction(lInteraction.lCreatedDate,lInteraction));
            }
            lReturn.lSuccessfulAttempts = lTopic.SolarCross_Author__c != 'Consumidor' && lTopic.SolarCross_Status__c == 'Sucesso' ? lReturn.lSuccessfulAttempts + 1 : lReturn.lSuccessfulAttempts;
            lReturn.lUnsuccessfulAttempts = lTopic.SolarCross_Author__c != 'Consumidor' && lTopic.SolarCross_Status__c == 'Insucesso' ? lReturn.lUnsuccessfulAttempts + 1 : lReturn.lUnsuccessfulAttempts;           
        }

        lReturn.lInteractionsLst.addAll(mapListInteraction.values());
        System.debug('lReturn.lInteractionsLst: ' + lReturn.lInteractionsLst);

        return lReturn;        
    }

    @AuraEnabled
    public static void updateInteraction(String strInteraction){
        Interaction objInteraction = (Interaction) JSON.deserialize(strInteraction, Interaction.class);
        vlocity_cmt__CustomerInteractionTopic__c objIntTopic = [SELECT Id, Comments__c FROM vlocity_cmt__CustomerInteractionTopic__c WHERE id =: objInteraction.lId LIMIT 1];
        objIntTopic.Comments__c = objInteraction.lCommentsManual;
        update objIntTopic;
    }

    public class InteractionHistory{
        @AuraEnabled public List<ListInteraction> lInteractionsLst;
        @AuraEnabled public Integer lSuccessfulAttempts;
        @AuraEnabled public Integer lUnsuccessfulAttempts;

        public InteractionHistory(){
            lInteractionsLst = new List<ListInteraction>();
            lSuccessfulAttempts = 0;
            lUnsuccessfulAttempts = 0;
        }
    }

    public class ListInteraction{
        @AuraEnabled public Datetime lDateKey;
        @AuraEnabled public List<Interaction> lInteractionsLst;

        ListInteraction(Datetime dateKey,Interaction interaction ){
            this.lDateKey = dateKey;
            this.lInteractionsLst = new list<Interaction>{interaction};
        }
    }
    public class Interaction{
        @AuraEnabled public String lId;
        @AuraEnabled public String lStatus;
        @AuraEnabled public String lChannel;
        @AuraEnabled public String lAuthor;
        @AuraEnabled public String lComments;
        @AuraEnabled public String lCommentsManual;
        @AuraEnabled public String lType;
        @AuraEnabled public String lFooterIcon;
        @AuraEnabled public String lFooterVariant;
        @AuraEnabled public String lClaroLogin;
        @AuraEnabled public String lCallId;
        @AuraEnabled public DateTime lCreatedDate;
    }
}