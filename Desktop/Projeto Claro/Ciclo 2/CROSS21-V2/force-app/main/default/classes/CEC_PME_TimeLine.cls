/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
Classe que contém a lógica que monta o path da ordem utilizado pelo compoente CEC_PME_Timeline.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public with sharing class CEC_PME_TimeLine {
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 5]
    	Método criado para criar o Path que deve ser exibido no componente tendo em vista o agrupamento de valores
    	previsto na configuração personalizada OrderTimeLineGroup__c.
    	Nem todo status deve ser exibido. Quando um grupo é configurado, apenas um item deve grupo deve ser exibido em tela.
*/	
    @AuraEnabled
    public static List<TimeLine> getTimeLine(String Id){
        List<TimeLine> lstTM = new List<TimeLine>();
        Map<String, String> nomeGrupo = new Map<String, String>(); 	//Mapa que armazena o nome do grupo tendo como chave o Status.
        Set<String> statusJaAdicionado = new Set<String>();  		//Set que armazena o status do grupo que já foi adicionado. Desconsiderando assim os demais status do mesmo grupo.
        
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        Boolean isIncomplete = false;								//Demarca o ponto de quando o Loop encontra o status atual do pedido.
        
        /*
        	Lista utilizada para obter as alterações no Status.
        	É utilizada para obter a descrição do Status que deve ser apresentado em tela enquanto não é encontrado o Status atual do pedido.
        */
        List<OrderHistory> historyOrder = [SELECT CreatedDate, NewValue FROM OrderHistory WHERE OrderId =: Id and Field = 'Status' Order By CreatedDate Desc];
        
        for(OrderTimeLineGroup__c grupoStatus : [SELECT NomeGrupo__c, Status__c FROM OrderTimeLineGroup__c Order By NomeGrupo__c]){
        	nomeGrupo.put(grupoStatus.Status__c, grupoStatus.NomeGrupo__c);	
        }
        
        Order item = [SELECT status FROM ORDER WHERE Id =: Id];
        

        for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
            TimeLine tm = new TimeLine();
            tm.DescricaoFase = f.getValue();
        
        	If(item.Status == f.getValue()){
                tm.option = 'slds-path__item slds-is-current';
                isIncomplete = true;
            } else if(isIncomplete){
                tm.option = 'slds-path__item slds-is-incomplete';
            } else {
                tm.option = 'slds-path__item slds-is-complete slds-is-active';
            }
            
            if(nomeGrupo.containsKey(f.getValue())){
        		String grupoAtual = nomeGrupo.get(f.getValue());
        		String grupoOrder = nomeGrupo.get(item.status);
        		
        		if(grupoAtual == grupoOrder){
        			if(item.status != f.getValue()){
        				continue;
        			}
        		} else {
		        	if(statusJaAdicionado.contains(nomeGrupo.get(f.getValue()))){
			        	continue;
			        } else if(!isIncomplete){
			        	for(OrderHistory itemHistory : historyOrder){
			        		if(grupoAtual == nomeGrupo.get((String)itemHistory.NewValue)){
			        			tm.DescricaoFase = (String)itemHistory.NewValue;
			           			statusJaAdicionado.add(nomeGrupo.get(f.getValue()));
			           			continue;	
			        		}
			        	}
		        	} else {
			        	tm.DescricaoFase = nomeGrupo.get(f.getValue());
			           	statusJaAdicionado.add(nomeGrupo.get(f.getValue()));
			        }	
        		}
            }
            
            lstTM.add(tm);    
        }
        
        return lstTM;
    }
    
    public class TimeLine{
        @AuraEnabled public String DescricaoFase;
        @AuraEnabled public String option;
    }    
}