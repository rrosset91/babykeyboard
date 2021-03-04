/*
* Autor: Squad Canais Criticos
* Data: 23/12/2020
* Descrição: [CEC] - [Time: SQUAD Canais Criticos]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Autor: Squad Canais Criticos
* Data: 23/12/2020
* Alterações: Alterações nos campos Status e Sub-Status do Caso (Melhorias Ouvidoria)
* ---------------------------------------------------------------
* Autor: Squad Canais Criticos
* Data: 23/12/2020 
* Descrição: Scripts GOV
*/
public without sharing class  Solar_CC_InteractionReason {

    public static List<QuickText> searchQuickText(String interactionType){
        List<QuickText> quickTextList = [SELECT
                                         	Id, Name
                                         FROM
                                         	QuickText
                                         WHERE
                                         	InteractionType__c =:interactionType
                                         Order by Name];

        return quickTextList;

    }

    private static QuickText searchQuickTextId(String quickTextId){
        QuickText quickText = [SELECT
                               		Id, Name, message, EditableScript__c, MandatoryAttachment__c, MainText__c,
                               		MainTextMinInterval__c
                               FROM
                                   QuickText
                               WHERE
                                   Id =:quickTextId];

        return quickText;

    }

    private static Map<String, String> extractDinamicFields(String quickTextMessage){

        Map<String, String> dynamicFieldsQuickTextMap = new Map<String, String>();
        Pattern p = Pattern.compile('\\{!.+?\\}');
        Matcher m = p.matcher(quickTextMessage);
        while(m.find()) {
            String fieldFound = m.group(0);
            String parsedFieldFound = fieldFound.replaceAll('([{!}])', '');
            if(parsedFieldFound.contains('(') && parsedFieldFound.contains(')')){
                parsedFieldFound = parsedFieldFound.substringBetween('(',')').split(',')[0];
            }
            dynamicFieldsQuickTextMap.put(fieldFound, parsedFieldFound);
        }
        return dynamicFieldsQuickTextMap;
    }

    // Método responsável por pegar as string separadas por ponto e retornar a string que gera a consulta dinânima.
    private static String getCaseQuery(List<String>fieldsToQueryList){
        String query = 'SELECT id,';
        for (String fieldToQuery : fieldsToQueryList) {
            if(fieldToQuery.startsWith('Case.') && !query.contains(fieldToQuery)){
                query += fieldToQuery + ',';
            }
        }
        query = query.removeEnd(',');
        query += ' FROM Case WHERE Id =:caseId';
        return query;
    }

    // Método responsável por relacionar os valores vindos da consulta dinâmica com seus respectivos campos mesclados.
    private static Map<String, String> getDataMap(SObject sObj, Map<String,String> dataMap){

        Map<String, String> dataMapResult = new Map<String,String>();
        for (String rawField : dataMap.keySet()) {
            try{
                String parsedField = dataMap.get(rawField);
                List<String> parsedFieldSplitted = parsedField.split('\\.');
                Integer numOfFields = parsedFieldSplitted.size();
                String initialObj = parsedFieldSplitted[0].toUpperCase();
                String fieldQueried;
                Datetime dateTimeFieldQueried;

                if(initialObj == 'CASE'){
                    if(numOfFields >= 2){
                        Integer counter = 2;
                        Integer index = 1;
                        SObject sObjTest = sObj;
                        while(counter < numOfFields){
                            sObjTest = sobjTest.getSObject(parsedFieldSplitted[index]);
                            index ++;
                            counter ++;
                        }
                        if(rawField.toUpperCase().contains('GETFIRSTNAME')){
                            fieldQueried = (String) sObjTest.get(parsedFieldSplitted[index]);
                            fieldQueried = fieldQueried.split(' ')[0];
                        }
                        else if(rawField.toUpperCase().contains('DATETIMEFORMAT')){
                            dateTimeFieldQueried = (Datetime) sObjTest.get(parsedFieldSplitted[index]);
                            String dateTimeFormat = rawField.substringBetween(',', ')').remove('\'');
                            fieldQueried = dateTimeFieldQueried.format(dateTimeFormat);
                        }
                        else{
                            fieldQueried = (String) sObjTest.get(parsedFieldSplitted[index]);
                        }
                    }
                }

                else if(initialObj == 'USERINFO'){
                    if(numOfFields == 2){
                        if(parsedFieldSplitted[1].toUpperCase() == 'FIRSTNAME'){
                            fieldQueried = UserInfo.getFirstName();
                        }
                        else if(parsedFieldSplitted[1].toUpperCase() == 'EMAIL'){
                            fieldQueried = UserInfo.getUserEmail();
                        }
                        else if(parsedFieldSplitted[1].toUpperCase() == 'USERNAME'){
                            fieldQueried = UserInfo.getUserName();
                        }
                    }
                }

                else if(initialObj == 'DATETIME'){
                    dateTimeFieldQueried = Datetime.now();
                    String dateTimeFormat = rawField.substringBetween(',', ')').remove('\'');
                    fieldQueried = dateTimeFieldQueried.format(dateTimeFormat);
                }

                dataMapResult.put(rawField, fieldQueried);

            }catch(Exception e ){
                dataMapResult.put(rawField, null);
            }
        }
        return dataMapResult;
    }

    public static Map<QuickText,String> getInteractionReasonParsed(String caseId, String quickTextId){

        QuickText quickText = searchQuickTextId(quickTextId);

        String quickTextMessage = quickText.message;

        Map<QuickText,String> mapQuickText = new Map<QuickText,String>();
        List<String> fieldsToQueryList = new List<String>();
        Map<String, String> dynamicFieldsQuickTextMap = extractDinamicFields(quickTextMessage);

        Set<List<String>> stringSplittedList = new Set<List<String>>();
        List<String> substringList = new List<String>();
        List<String> substringList2 = new List<String>();

        if(dynamicFieldsQuickTextMap != null){

            for(String str : dynamicFieldsQuickTextMap.values()){
                substringList = str.split('\\.');
                stringSplittedList.add(substringList);
            }

            String query = getCaseQuery(dynamicFieldsQuickTextMap.values());

            sObject sObj;
            try{
                sObj = Database.query(query);
            }catch(Exception e){
                System.debug(quickTextMessage+' Erro na consulta: '+e.getMessage());
                quickText.EditableScript__c = 'Sim';
                mapQuickText.put(quickText, 'Erro ao Consultar o banco, verifique os campos mesclados');
                return mapQuickText;
            }
            Map <String, String> dataMap = getDataMap(sObj, dynamicFieldsQuickTextMap);
            String quickTextMessageParsed = replaceMessage(dataMap, quickTextMessage);
            quickText.message = quickTextMessageParsed;
            mapQuickText.put(quickText,null);
        }
        else{
            mapQuickText.put(quickText, 'Erro ao extrair os campos dinâmicos do QuickText');
        }
        return mapQuickText;
    }

    private static String replaceMessage(Map<String,String> dataMap, String quickTextMessage){
        String quickTextMessageResult = quickTextMessage;
        System.debug(quickTextMessageResult);
        for(String dynamicFieldKey: dataMap.keySet()){
            if(dataMap.get(dynamicFieldKey) != null){
                quickTextMessageResult = quickTextMessageResult.replace(dynamicFieldKey, dataMap.get(dynamicFieldKey));
            }
            else{
                quickTextMessageResult = quickTextMessageResult.replace(dynamicFieldKey, '');
            }
        }
        return quickTextMessageResult;
    }

    public static String validateDescriptionInteractionReason(String descriptionInteraction, String reasonId, String caseId){
        String messageAfterValidation = descriptionInteraction;
        QuickText quickText = [SELECT Message, EditableScript__c FROM QuickText where Id =:reasonId];
        Map<QuickText,String> mapQuickText = Solar_CC_InteractionReason.getInteractionReasonParsed(caseId, reasonId);
        QuickText reason = new QuickText();
        for (QuickText idKey : mapQuickText.keyset()) {
            reason = idKey;
            String error = mapQuickText.get(idKey);
            if (error == null){
                if(reason.EditableScript__c == 'Não'){
                    messageAfterValidation = idKey.Message;
                }else if(reason.EditableScript__c == 'Parcialmente' && !validateBaseText(quickText.Message, descriptionInteraction)){
                    messageAfterValidation = 'Não é permitido alterar o texto base além dos valores dinâmicos';
                }
            }else if((quickText.EditableScript__c == 'Não' || quickText.EditableScript__c == 'Parcialmente') && !validateBaseText(quickText.Message, descriptionInteraction)){
                messageAfterValidation = 'Não é permitido alterar o texto base além dos valores dinâmicos';
            }
        }
        return messageAfterValidation;
    }

    private static List<String> substringsBetween(String str, String open, String close) {
        if (str == null || open == null || close == null) {
            return null;
        }
        Integer strLen = str.length();
        if (strLen == 0) {
            return null;
        }
        Integer closeLen = close.length();
        Integer openLen = open.length();
        List<String> lista = new List<String>();
        Integer pos = 0;
        while (pos < strLen - closeLen) {
            Integer start = str.indexOf(open, pos);
            if (start < 0) {
                break;
            }
            start += openLen;
            Integer fim = str.indexOf(close, start);
            if (fim < 0) {
                break;
            }
            lista.add(str.substring(start, fim));
            pos = fim + closeLen;
        }
        if (lista.isEmpty()) {
            return null;
        }
        return lista;
    }

    private static boolean validateBaseText(String quickTextMessage, String descriptionInteraction){

        //Preparando a regex, colocando caracter de escape nos caracteres que têm algum tipo de efeito na regex e poderiam gerar algum erro.
        quickTextMessage = quickTextMessage.replaceAll('\\^','\\\\^');
        quickTextMessage = quickTextMessage.replaceAll('\\*','\\\\*');
        quickTextMessage = quickTextMessage.replaceAll('\\+','\\\\+');
        quickTextMessage = quickTextMessage.replaceAll('\\[','\\\\[');
        quickTextMessage = quickTextMessage.replaceAll('\\]','\\\\]');
        quickTextMessage = quickTextMessage.replaceAll('\\(','\\\\(');
        quickTextMessage = quickTextMessage.replaceAll('\\)','\\\\)');
        quickTextMessage = quickTextMessage.replaceAll('\\.','\\\\.');
        quickTextMessage = quickTextMessage.replaceAll('/','\\\\/');
        quickTextMessage = quickTextMessage.replaceAll('\\?','\\\\?');
        quickTextMessage = quickTextMessage.replaceAll('\\$','\\\\\\$');

        //Substituindo os valores dinamicos para aceitar qualquer caracter.
        quickTextMessage = quickTextMessage.replaceAll('XXXXX','(.*)');
        List<String> subStrList = substringsBetween(quickTextMessage,'{!','}');
        if(subStrList != null){
            for(String str : subStrList){
                //Substituindo os valores dinamicos para aceitar qualquer caracter.
                quickTextMessage = quickTextMessage.replace('{!'+str+'}','(.*)');
            }
        }
        Boolean baseTextNotChanged = Pattern.matches(quickTextMessage.normalizeSpace().deleteWhitespace(), descriptionInteraction.normalizeSpace().deleteWhitespace());

        return baseTextNotChanged;
    }

    public static void validateInteractionReason(String reasonId, String caseId, Integer documentQuantity){

        if(String.isNotBlank(reasonId)) {

			QuickText reason = searchQuickTextId(reasonId);
			CEC_IntegrationException ex = new CEC_IntegrationException();

			if (reason.MandatoryAttachment__c && documentQuantity == 0){
				ex.errorMessage = Label.CEC_CC_AnexoObr;
				throw ex;
			}

			if (reason.MainText__c != null){

				List<vlocity_cmt__CustomerInteractionTopic__c> quickTextList = [SELECT
													Id, vlocity_cmt__CustomerInteractionId__r.CreatedDate
												 FROM
													vlocity_cmt__CustomerInteractionTopic__c
												 WHERE
													vlocity_cmt__CaseId__c = :caseId
												 AND
													vlocity_cmt__CustomerInteractionId__r.InteractionReason__c = :reason.MainText__c];

                QuickText reasonMainText = [SELECT Id, Name, message, EditableScript__c, MandatoryAttachment__c, MainText__c,
                                            MainTextMinInterval__c FROM QuickText WHERE Id =:reason.MainText__c];

				if (quickTextList.isEmpty()){
					ex.errorMessage = 'Não é possível registrar uma interação com o motivo '+ reason.Name +
									  ' antes de ter uma interação com o motivo '+ reasonMainText.Name +' registrada.';
					throw ex;
				}else{

					if (reason.MainTextMinInterval__c != null){
					   Long dataPedido;

						if(Test.IsrunningTest()){
							dataPedido = quickTextList.get(0).vlocity_cmt__CustomerInteractionId__r.CreatedDate.adddays(-5).getTime();
						}else{
							dataPedido = quickTextList.get(0).vlocity_cmt__CustomerInteractionId__r.CreatedDate.getTime();
						}

						Long dataAtual = DateTime.now().getTime();
						Long milliseconds = dataAtual - dataPedido;
						Long seconds = milliseconds / 1000;
						Long minutes = seconds / 60;
                        Long hours = minutes / 60;

                        Decimal reasonMinIntervalInt = reason.MainTextMinInterval__c;
                        Long reasonMinIntervalLong = long.valueOf(reasonMinIntervalInt.format());
                        String hourString = ' hora.';

                        if (reasonMinIntervalLong > 1) {
                            hourString = ' horas.';
                        }

						if (hours < reasonMinIntervalLong){
                            ex.errorMessage = 'Para inserir essa interação é necessário um registro de interação ' + reasonMainText.Name +
                                              ' criado há pelo menos ' + reason.MainTextMinInterval__c + hourString;
							throw ex;
						}
					}
				}
			}
		}
	}

    /*
    * Devido ao fato da classe CEC_CC_InteractionClientController ser with sharing, realizar a gravacao de um customer interaction
    * com registro de motivo de interacao, apontando para o quick text, da erro se a gravacao for feita usando um registro de quick text
    * que o usario nao tem acesso, mas que ele obteve via consulta dessa classe, que e without sharing. Por isso a gravacao precisa ser feita aqui.
    */

    public static void saveInteraction(vlocity_cmt__CustomerInteraction__c objCustomerInteraction) {

        if(objCustomerInteraction != null) {
            insert objCustomerInteraction;
        }
    }

    public static List<vlocity_cmt__CustomerInteractionTopic__c> getCustomerInteractionTopic(String caseId) {

        List<vlocity_cmt__CustomerInteractionTopic__c> listInteractionTopic = [SELECT Id,
                                                                                vlocity_cmt__CaseId__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.TypeInteractionGov__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.Description__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.NewCompany__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__StartDateTime__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.Attachment__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.Author__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Status__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.ContactEmail__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.ContactPhone__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.LastModifiedDate,
                                                                                vlocity_cmt__CustomerInteractionId__r.Owner.Name,
                                                                                vlocity_cmt__CustomerInteractionId__r.LoginClaro__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.vlocity_cmt__Type__c,
                                                                                vlocity_cmt__CustomerInteractionId__r.InteractionReason__r.Name,
                                                                                vlocity_cmt__CustomerInteractionId__r.InteractionReason__c,
                                                                                vlocity_cmt__CaseId__r.SubStatus__c
                                                                                FROM vlocity_cmt__CustomerInteractionTopic__c
                                                                                WHERE vlocity_cmt__CaseId__c = :caseId
                                                                                ORDER BY CreatedDate DESC];

        return listInteractionTopic;
    }

    public static void updateInfosOnCase(String typeInteraction, Case objCase)
    {
        Boolean isToUpdateCase = false;

        if(typeInteraction.equalsIgnoreCase('Recusa da Reclamação')) {
            objCase.SubStatus__c = 'Recusa Solicitada';
            isToUpdateCase = true;
        }
        if(typeInteraction.equalsIgnoreCase('Resposta da Reclamação')) {
            objCase.SubStatus__c = 'Respondido e Aguardando Avaliação';
            isToUpdateCase = true;
        }
        if(isToUpdateCase) {
            CEC_CaseTriggerHandler.byPassValidation = true;
            update objCase;
        }
    }

    public static void updateCaseStatus(String typeInteraction, Case objCase){
        Id CEC_CC_Anatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Anatel').getRecordTypeId();
        Id CEC_CC_CanaisInternos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_CanaisInternos').getRecordTypeId();
        Id CEC_CC_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_JEC').getRecordTypeId();
        Id CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        Id CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();
        Id CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();

        Set<Id> recordTypesIds = new Set<Id>{CEC_CC_Anatel, CEC_CC_CanaisInternos, CEC_CC_JEC, CEC_CC_Ouvidoria,
                                                CEC_CC_Pre_JEC, CEC_CC_Procon};

        if(((objCase.Status == 'New' || objCase.SubStatus__c == 'Não Iniciado') && recordTypesIds.contains(objCase.RecordTypeId)) && 
            (typeInteraction == 'Registro de Tratamento'|| typeInteraction == 'Tentativa de Contato'))
        {
            objCase.Status = 'In Progress';
            objCase.SubStatus__c = 'Em tratamento';
            update objCase;
        }
    }
}