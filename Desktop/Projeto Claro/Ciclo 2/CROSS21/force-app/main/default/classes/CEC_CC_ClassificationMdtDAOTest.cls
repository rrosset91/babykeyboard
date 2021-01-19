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
      
        // Teste 1
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{'Claro'}, 
                                                              new Set<String>{'Pré'});
        system.debug('mapClassification: ' + mapClassification);
        system.assertEquals(true, mapClassification.containsKey('Claro'), 'Erro! Classificação Claro x Pré não encontrada.');

        // Teste para buscar a classificacao das mascaras que contem o Tipo de Registro como nulo (que sao de Canais Criticos)
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification2 = 
        CEC_CC_ClassificationMdtDAO.getClassificationTypeRecordTypeNull(new Set<String>{'Claro'}, 
                                                                        new Set<String>{'Pré'});

        System.debug('mapClassification2 >>>>>>>>' + mapClassification2);
        
        system.assertEquals(true, mapClassification2.containsKey('Claro'), 'Erro! Classificação Claro x Pré não encontrada.');
        
        // Teste 3
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapAllClassification = 
            CEC_CC_ClassificationMdtDAO.getAllClassificationType();

        System.debug('mapAllClassification >>>>>>>>' + mapAllClassification);
        
        system.assertEquals(true, mapAllClassification.size() > 0, 'Erro! Nenhuma classificação foi não encontrada.');

        // Teste para buscar classificação das máscaras com Tipo de Registro definido
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification3 = 
        CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{'Claro'},
                                                          new Set<String>{'Pré'},
                                                          new Set<String>{'Financial'});

        System.debug('mapClassification3 >>>>>>>>' + mapClassification3);
        
        system.assertEquals(true, mapClassification3.containsKey('ClaroFinancial'), 'Erro! Classificação Claro x Pré não encontrada.');

    }
}