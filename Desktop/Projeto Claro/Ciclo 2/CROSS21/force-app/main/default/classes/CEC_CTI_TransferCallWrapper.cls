/*
* Autor: Diego Lima - Deloitte
* Data: 27/08/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Classe utilizada como Wrapper para a
* funcionalidade de transferência de chamada]
* 
*/

global class CEC_CTI_TransferCallWrapper {

    public String transferName {get; set;}
    public String vdnToDriver {get; set;}
    
    public String firstNodeName {get; set;}
    public String firstNodeVDN {get; set;}
    public String secondNodeName {get; set;}
    public String secondNodeVDN {get; set;}
    public String thirdNodeName {get; set;}
    public String thirdNodeVDN {get; set;}
    
    public List<Transferencia__c> set1Nivel = new List<Transferencia__c>();
    public List<Transferencia__c> set2Nivel = new List<Transferencia__c>();
    public Set<Transferencia__c> set3Nivel = new Set<Transferencia__c>();	
}