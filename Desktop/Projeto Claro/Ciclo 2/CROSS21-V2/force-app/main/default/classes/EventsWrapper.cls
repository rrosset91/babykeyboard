/**
* @author: Caio Cesar Leite de Oliveira
* @company: IBM - Bluewolf
* @description: do tipo wrapper para reunir as informações dos eventos
*/
public class EventsWrapper {
	@AuraEnabled
    public String cityId;
    @AuraEnabled
    public String operatorCode;
    @AuraEnabled
    public String contractNumber;
    @AuraEnabled
    public Integer requestID ;
    @AuraEnabled
    public Integer requestTypeID ;
    @AuraEnabled
    public String requestTypeDescription;
    @AuraEnabled
    public Integer status ;
    @AuraEnabled
    public String statusDescription ;
    @AuraEnabled
    public String closeDate ;
    @AuraEnabled
    public String closeUser;
    @AuraEnabled
    public String openUser ;
    @AuraEnabled
    public String obs ;
    @AuraEnabled
    public Integer cancelReasonID ;
    @AuraEnabled
	public String cancelReasonDescription ;
	@AuraEnabled
    public String groupType ;
}