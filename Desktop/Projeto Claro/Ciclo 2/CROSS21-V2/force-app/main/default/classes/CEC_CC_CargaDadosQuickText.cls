/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-21-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                                    Modification
 * 1.0   12-16-2020   David Samerson - Claro Canais Críticos    Initial Version
**/

public with sharing class CEC_CC_CargaDadosQuickText {

    /**
     * Inicia a carga
     */
    public static void run() {

        String staticResourceName = 'cargaDadosQuickText';

        //Limpando os registros antes de atualizar
        delete [Select id from QuickText where Category = 'Motivo de Interação'];

        List<QuickText> quickTexts = new List<QuickText> (); // List para inserção de quick
        Map<String, Id> pesquisaQuickText = new Map<String, Id>();
        List<QuickText> quickTextsUpdate = new List<QuickText> (); // List para atualização de quick text com o id do pai.
        Map<String, String> searchFather = new Map<String, String>(); // Adiciona o quickText e seu respectivo pai

        StaticResource sr = [SELECT ID, body FROM StaticResource WHERE Name =: staticResourceName LIMIT 1]; // Busca o TXT separado por ; obrigatoriamente
        if(sr != null && sr.body != null) {
            String csv = sr.Body.toString();
            String [] csvRow = csv.split('\n'); // Separa por linha

            if(String.isNotBlank(csv)) {

                for (integer i = 1 ; i < csvRow.size(); i++)  {// pula a primeira linha, pois a primeira é de ApiName
                    String [] valoresLinha =csvRow[i].split(';'); //quebro os valores da linha e deixo em um array, criando as colunas
                    QuickText qt = new QuickText ();

                    if(String.isNotBlank(valoresLinha[0])){
                        qt.Category = 'Motivo de Interação';
                        qt.InteractionType__c = valoresLinha[0];
                        qt.Name = valoresLinha[1];
                        qt.Message = valoresLinha[2];
                        searchFather.put(valoresLinha[1], valoresLinha[3]); // adiciona o pai na pesquisa
                        qt.MandatoryAttachment__c = Boolean.valueOf(valoresLinha[4]);
                        if(String.isNotBlank(valoresLinha[5])){
                            qt.EditableScript__c = valoresLinha[5];
                        }
                        if(valoresLinha.size() > 6 && String.isNotBlank(valoresLinha[6])){
                            qt.MainTextMinInterval__c = Double.valueOf(valoresLinha[6]);
                        }
                        quickTexts.add(qt);
                    }

                }
                
                insert quickTexts;

                //montando a pesquisa de quick text
                for(QuickText qt : quickTexts){
                    pesquisaQuickText.put(qt.Name, qt.Id);
                }

                for(QuickText qt : quickTexts){
                    if(String.isNotBlank(searchFather.get(qt.Name))){
                        qt.MainText__c = pesquisaQuickText.get(searchFather.get(qt.Name));//  retorna o nome do pai e atribui o id dele no campo
                        quickTextsUpdate.add(qt);
                    }
                }

                update quickTextsUpdate;

            }

            
        }
    }
}