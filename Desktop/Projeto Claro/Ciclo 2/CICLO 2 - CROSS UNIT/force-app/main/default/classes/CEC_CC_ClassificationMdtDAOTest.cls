/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 11/02/2020 
* Descrição: [CEC - Extensão Fase 2] - [Time: SQUAD Canais Criticos - Sprint 17]
*	         Classificação dos casos para tratativa de integração (tabulações)
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
@istest
public class CEC_CC_ClassificationMdtDAOTest { 
    
    @isTest
    private static void validateMethods()
    {
      
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{'Claro'}, 
                                                              new Set<String>{'Pré'});
        system.debug('mapClassification: ' + mapClassification);
        system.assertEquals(true, mapClassification.containsKey('Claro'), 'Erro! Classificação Claro x Pré não encontrada.');
        
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapAllClassification = 
            CEC_CC_ClassificationMdtDAO.getAllClassificationType();
        
        system.assertEquals(true, mapAllClassification.size() > 0, 'Erro! Nenhuma classificação foi não encontrada.');
    }
    
}