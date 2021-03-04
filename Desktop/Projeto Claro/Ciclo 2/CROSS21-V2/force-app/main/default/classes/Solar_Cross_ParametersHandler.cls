/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Parameters__c Trigger Handler
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version   1.0    2020-10-22      Jean Sganzerla          class created
**************************************************************************************************************/
public class Solar_Cross_ParametersHandler {
    public static Boolean firstRun = true;
    private static final Id ATTENDENCE_TREE_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AttendanceTree').getRecordTypeId();
    private static final Id OFFER_MATRIX_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('OfferMatrix').getRecordTypeId();
    private static Integer lastInstallmentSequence;

    //Desabilita a trigger caso haja um registro com o nome do objeto marcado com Active__c false no custom setting Solar_Cross_TriggerConfiguration__c
    public static Boolean isActive(String aObjName) {
        Solar_Cross_TriggerConfiguration__c lConf = Solar_Cross_TriggerConfiguration__c.getValues(aObjName);
        Boolean isActive = lConf == null || lConf.Active__c ? true : false;
        return isActive;
    }

    //Método que impede que um registro de Parâmetro, do tipo "Árvore de Atendimento" seja criado em duplicidade;
    //Foi descartado o uso de regra de duplicata, pois estão sendo utilizados campos picklist para fazer a correspondência;
    public static void validateDuplicatedAttendenceTree(Map<Id,Parameters__c> aOldMap, List<Parameters__c> aNewLst){

        List<Parameters__c> lRecordsToValidateLst = new List<Parameters__c>();
        //valida se o registro é do tipo 'Árvore de atendimento E (se é novo OU se os campos chave foram alterados)'
        for(Parameters__c lParam :aNewLst){
            if(lParam.RecordTypeId == ATTENDENCE_TREE_RECTYPE && ((aOldMap == null || !aOldMap.containsKey(lParam.Id) ||
            (aOldMap.get(lParam.Id).Channel__c != lParam.Channel__c || aOldMap.get(lParam.Id).Business_Unit__c != lParam.Business_Unit__c || aOldMap.get(lParam.Id).FirstCallResolution__c != lParam.FirstCallResolution__c)))){
                lRecordsToValidateLst.add(lParam);
            }
        }
        system.debug('lRecordsToValidateLst ' + lRecordsToValidateLst);
        if(lRecordsToValidateLst.isEmpty()) return;

        Map<String,String> lExistingRecordsMap = new Map<String,String>();
        for(Parameters__c lParam :[SELECT Id, Channel__c, Business_Unit__c, FirstCallResolution__c FROM Parameters__c WHERE RecordTypeId =: ATTENDENCE_TREE_RECTYPE]){
            lExistingRecordsMap.put(lParam.Channel__c + ';' + lParam.Business_Unit__c + ';' + lParam.FirstCallResolution__c, lParam.Id);
        }

        for(Parameters__c lParam :lRecordsToValidateLst){
            String lInvalid = lParam.Channel__c + ';' + lParam.Business_Unit__c + ';' + lParam.FirstCallResolution__c;
            if(lExistingRecordsMap.containsKey(lInvalid)){
                lParam.addError(Label.Solar_Cross_ParametersDuplicatedError + ' Registro existente: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Parameters__c/' +  lExistingRecordsMap.get(lInvalid) + '/view');
            }
        }
    }
    //110663 - [Atendimento - Financeiro] USF - [Negociação] Melhoria - Parâmetros de Ofertas de negociação
    public static void validateInsertOfferMatriz(Map<Id,Parameters__c> aOldMap, List<Parameters__c> aNewLst){
        Map<String, String> errorMessage= new Map<String, String>();

        Set<String>  setValidateDuplicateInsert= new Set<String>();
        Map<String, List<InstallmentWrapper>>  mapGroupInsert = new  Map<String, List<InstallmentWrapper>> ();
        Map<String, List<InstallmentWrapper>>  mapGroupBase = new  Map<String, List<InstallmentWrapper>> ();

        InstallmentWrapper installment = new InstallmentWrapper();

        for(Parameters__c lParam :aNewLst){
            System.debug('lParam ==>' + lParam);

            if(lParam.RecordTypeId == OFFER_MATRIX_RECTYPE && lParam.Active__c){

                // Group parameters by Customer and Contract KeyValues
                String groupKeySequence = lParam.DefaultTargeting__c + lParam.AnatelProconProneTargeting__c + lParam.Segment__c  + String.valueOf(Integer.valueOf(lParam.DebtLimitValue__c));
                if(!mapGroupInsert.containsKey(groupKeySequence)){
                    mapGroupInsert.put(groupKeySequence, new List<InstallmentWrapper>());
                }
                installment = new InstallmentWrapper();
                installment.installmentNumber = Integer.ValueOf(lParam.Installments__c);
                installment.installmentData = lParam;
                mapGroupInsert.get(groupKeySequence).add(installment);


                // Validate Duplicate value on Insert
                String keyInstallments = groupKeySequence + lParam.Installments__c + String.valueOf(Integer.valueOf(lParam.InstallmentDiscount__c)) ;
                if(setValidateDuplicateInsert.contains(keyInstallments)){
                    errorMessage.put(groupKeySequence, System.Label.Solar_Financial_ParameterMatrixErrorDouble);
                }else{
                    setValidateDuplicateInsert.add(keyInstallments);
                }

            }
        }

        System.debug('mapGroupInsert ==>' + mapGroupInsert.keySet());

        if(!mapGroupInsert.isEmpty()){
            List<Parameters__c> lstParams = new List<Parameters__c>();
            lstParams = [
                SELECT
                    Installments__c,
                    Name,
                    DefaultTargeting__c,
                    AnatelProconProneTargeting__c,
                    Segment__c,
                    InstallmentDiscount__c,
                    DebtLimitValue__c
                FROM Parameters__c
                WHERE
                    RecordTypeId =: OFFER_MATRIX_RECTYPE
                AND
                    Active__c = TRUE
                ORDER BY
                    Installments__c
                DESC
            ];
            // System.debug('lstParams ==>' + JSON.serialize(lstParams));

            if(!lstParams.isEmpty()){
                for (Parameters__c param : lstParams) {
                    String groupKeySequence = param.DefaultTargeting__c + param.AnatelProconProneTargeting__c + param.Segment__c + String.valueOf(Integer.valueOf(param.DebtLimitValue__c));
                    String keyInstallments = groupKeySequence + param.Installments__c + String.valueOf(Integer.valueOf(param.InstallmentDiscount__c));

                    // Validate Duplicate value on Insert with base
                    if(setValidateDuplicateInsert.contains(keyInstallments)){
                        String strMsg = System.Label.Solar_Financial_ParameterMatrixErrorDoubleId;
                        strMsg = strMsg.replace('_URLSALESFORCE_', URL.getSalesforceBaseUrl().toExternalForm());
                        strMsg = strMsg.replace('_PARAMID_', param.id);
                        errorMessage.put(groupKeySequence, strMsg);
                    }


                    if(!mapGroupBase.containsKey(groupKeySequence)){
                        mapGroupBase.put(groupKeySequence, new List<InstallmentWrapper>());
                    }
                    installment = new InstallmentWrapper();
                    installment.installmentNumber = Integer.ValueOf(param.Installments__c);
                    installment.installmentData = param;
                    mapGroupBase.get(groupKeySequence).add(installment);
                }
            }
            System.debug('mapGroupBase ==>' + JSON.serializePretty(mapGroupBase));

            //Passo 4 - Validar se o parametro inserido/atualizado esta na sequencia do Installments__c
            for (String groupKeySequence : mapGroupInsert.keySet()) {
                System.debug('mapValidadeSequenceGrouped key ==> '+groupKeySequence+' <==');

                List<Integer> listInstallments = new List<Integer>();
                for (InstallmentWrapper installmentInsert : mapGroupInsert.get(groupKeySequence)) {
                    listInstallments.add(installmentInsert.installmentNumber);
                }

                if(mapGroupBase.containsKey(groupKeySequence)){
                    for (InstallmentWrapper installmentBase : mapGroupBase.get(groupKeySequence)) {
                        listInstallments.add(installmentBase.installmentNumber);
                    }
                }

                listInstallments.sort();

                if(!isSequence(listInstallments, true)){
                    if(errorMessage.get(groupKeySequence) == null){
                        if(lastInstallmentSequence == 0){
                            errorMessage.put(groupKeySequence, System.Label.Solar_Financial_ParameterMatrixErrorInitialSequence);
                        }else{
                            String strMsg = System.Label.Solar_Financial_ParameterMatrixErrorSequence;
                            strMsg = strMsg.replace('_LASTINSTALLMENT_', String.valueOf(lastInstallmentSequence));
                            errorMessage.put(groupKeySequence, strMsg);
                        }
                        lastInstallmentSequence = null;
                    }
                }
            }
        }
        System.debug('errorMessage ==> '+ JSON.serializePretty(errorMessage));
        if(errorMessage.size() > 0){
            for (Parameters__c paramTrg : aNewLst) {
                String groupKeySequence = paramTrg.DefaultTargeting__c + paramTrg.AnatelProconProneTargeting__c + paramTrg.Segment__c + String.valueOf(Integer.valueOf(paramTrg.DebtLimitValue__c));
                if(errorMessage.containsKey(groupKeySequence)){
                    paramTrg.addError(errorMessage.get(groupKeySequence));
                }
            }
        }
    }

    //110663 - [Atendimento - Financeiro] USF - [Negociação] Melhoria - Parâmetros de Ofertas de negociação
    public static void validateEditOfferMatriz(Map<Id,Parameters__c> aOldMap, List<Parameters__c> aNewLst){
        // List<Parameters__c> lRecordsToValidateLst = new List<Parameters__c>();
        Map<String, String> errorMessage= new Map<String, String>();

        Map<String, List<InstallmentWrapper>>  mapGroupBase = new  Map<String, List<InstallmentWrapper>> ();
        Map<Id,Parameters__c> mapParamUpdate = new Map<Id,Parameters__c>();

        InstallmentWrapper installment = new InstallmentWrapper();

        for(Parameters__c lParam :aNewLst){
            if(lParam.RecordTypeId == OFFER_MATRIX_RECTYPE){
                Parameters__c oldParam =  aOldMap.get(lParam.Id);
                String groupKeySequence = lParam.DefaultTargeting__c + lParam.AnatelProconProneTargeting__c + lParam.Segment__c + String.valueOf(Integer.valueOf(lParam.DebtLimitValue__c));

                if(lParam.DefaultTargeting__c != oldParam.DefaultTargeting__c ||
                    lParam.AnatelProconProneTargeting__c != oldParam.AnatelProconProneTargeting__c ||
                        lParam.Segment__c != oldParam.Segment__c ||
                            lParam.DebtLimitValue__c != oldParam.DebtLimitValue__c){
                    errorMessage.put(groupKeySequence, System.Label.Solar_Financial_ParameterMatrixErrorEditKeyFields);
                }else if(lParam.Installments__c != oldParam.Installments__c){
                    errorMessage.put(groupKeySequence, System.Label.Solar_Financial_ParameterMatrixErrorEditSequence);
                }else{
                    mapParamUpdate.put(lParam.Id, lParam);
                }
            }
        }
        System.debug('mapParamUpdate ==>' + JSON.serializePretty(mapParamUpdate));

        if(!mapParamUpdate.isEmpty()){
            List<Parameters__c> lstParams = new List<Parameters__c>();
            lstParams = [
                SELECT
                    Installments__c,
                    Name,
                    DefaultTargeting__c,
                    AnatelProconProneTargeting__c,
                    Segment__c,
                    InstallmentDiscount__c,
                    DebtLimitValue__c,
                    Active__c
                FROM Parameters__c
                WHERE
                    RecordTypeId =: OFFER_MATRIX_RECTYPE
                // AND
                //     Active__c = TRUE
                ORDER BY
                    Installments__c
                DESC
            ];
            System.debug('lstParams ==>' + JSON.serialize(lstParams));

            if(lstParams.size() > 0){
                for (Parameters__c paramBase : lstParams) {

                    String groupKeySequence = paramBase.DefaultTargeting__c + paramBase.AnatelProconProneTargeting__c + paramBase.Segment__c + String.valueOf(Integer.valueOf(paramBase.DebtLimitValue__c));
                    if(!mapGroupBase.containsKey(groupKeySequence)){
                        mapGroupBase.put(groupKeySequence, new List<InstallmentWrapper>());
                    }
                    installment = new InstallmentWrapper();
                    installment.installmentNumber = Integer.ValueOf(paramBase.Installments__c);
                    installment.installmentData = paramBase;
                    mapGroupBase.get(groupKeySequence).add(installment);
                }
            }
            System.debug('mapGroupBase ==>' + JSON.serializePretty(mapGroupBase));


            for(Parameters__c paramUpdate : mapParamUpdate.values()){
                String groupKeySequence = paramUpdate.DefaultTargeting__c + paramUpdate.AnatelProconProneTargeting__c + paramUpdate.Segment__c + String.valueOf(Integer.valueOf(paramUpdate.DebtLimitValue__c));
                System.debug('groupKeySequence ==>' + groupKeySequence );

                if(mapGroupBase.containsKey(groupKeySequence)){
                    Boolean groupChanged = false;
                    List<Integer> lstInstallment = new List<Integer> ();
                    for (InstallmentWrapper parcela : mapGroupBase.get(groupKeySequence)) {
                        System.debug('parcela ==>' + parcela );

                        if(mapParamUpdate.containsKey(parcela.installmentData.Id)){
                            System.debug('parcela update ==>' + mapParamUpdate.get(parcela.installmentData.Id));

                            if(mapParamUpdate.get(parcela.installmentData.Id).Active__c != parcela.installmentData.Active__c){
                                parcela.installmentData.Active__c = mapParamUpdate.get(parcela.installmentData.Id).Active__c;
                                groupChanged = true;
                            }
                        }

                        if(parcela.installmentData.Active__c){
                            if(lstInstallment.indexOf(parcela.installmentNumber) == -1){
                                lstInstallment.add(parcela.installmentNumber);
                            }else{
                                if(errorMessage.get(groupKeySequence) == null){
                                    errorMessage.put(groupKeySequence, System.Label.Solar_Financial_ParameterMatrixErrorActivationDouble);
                                }
                            }

                        }
                    }
                    if(groupChanged){
                        System.debug('lstInstallment ==>' + lstInstallment );

                        lstInstallment.sort();
                        if(!isSequence(lstInstallment, true)){
                            if(errorMessage.get(groupKeySequence) == null){
                                errorMessage.put(groupKeySequence, System.Label.Solar_Financial_ParameterMatrixErrorActivation);
                            }
                        }
                    }
                }
            }

        }
        System.debug('errorMessage ==>' + JSON.serializePretty(errorMessage));

        if(!errorMessage.isEmpty()){
            for(Parameters__c lParam :aNewLst){
                String groupKeySequence = lParam.DefaultTargeting__c + lParam.AnatelProconProneTargeting__c + lParam.Segment__c + String.valueOf(Integer.valueOf(lParam.DebtLimitValue__c));
                if(errorMessage.containsKey(groupKeySequence)){
                    lParam.addError(errorMessage.get(groupKeySequence));
                }
            }
        }
    }

    //110663 - [Atendimento - Financeiro] USF - [Negociação] Melhoria - Parâmetros de Ofertas de negociação
    public static void validateDeleteOfferMatriz(List<Parameters__c> aOldLst){
        System.debug('deleteOfferMatriz ==>' + JSON.serializePretty(aOldLst));

        //MAP<KEY, MAP<INSTALLMENT, PARAMETER>>
        Map<String, List<InstallmentWrapper>>  mapDeleteParam = new  Map<String, List<InstallmentWrapper>> ();
        //MAP<KEY, MAP<INSTALLMENT, PARAMETER>>
        Map<String, List<InstallmentWrapper>> mapBaseParam = new Map<String, List<InstallmentWrapper>>();

        InstallmentWrapper installment = new InstallmentWrapper();
        for(Parameters__c lParam :aOldLst){

            if(lParam.RecordTypeId == OFFER_MATRIX_RECTYPE  && lParam.Active__c){
                String groupKeySequence = lParam.DefaultTargeting__c + lParam.AnatelProconProneTargeting__c + lParam.Segment__c + String.valueOf(Integer.valueOf(lParam.DebtLimitValue__c));

                if(!mapDeleteParam.containsKey(groupKeySequence)){
                    mapDeleteParam.put(groupKeySequence, new List<InstallmentWrapper>());
                }
                installment = new InstallmentWrapper();
                installment.installmentNumber = Integer.ValueOf(lParam.Installments__c);
                installment.installmentData = lParam;
                mapDeleteParam.get(groupKeySequence).add(installment);
            }
        }
        // System.debug('mapDeleteParam ==>' + JSON.serializePretty(mapDeleteParam));

        if(!mapDeleteParam.isEmpty()){
            List<Parameters__c> lstParams = new List<Parameters__c>();
            lstParams = [
                SELECT
                    Id,
                    Installments__c,
                    Name,
                    DefaultTargeting__c,
                    AnatelProconProneTargeting__c,
                    Segment__c,
                    InstallmentDiscount__c,
                    DebtLimitValue__c,
                    Active__c
                FROM Parameters__c
                WHERE
                    RecordTypeId =: OFFER_MATRIX_RECTYPE
                AND
                    Active__c = TRUE
                ORDER BY
                    Installments__c
                DESC
            ];

            for (Parameters__c paramBase : lstParams) {
                String groupKeySequence = paramBase.DefaultTargeting__c + paramBase.AnatelProconProneTargeting__c + paramBase.Segment__c + String.valueOf(Integer.valueOf(paramBase.DebtLimitValue__c));

                if(!mapBaseParam.containsKey(groupKeySequence)){
                    mapBaseParam.put(groupKeySequence, new List<InstallmentWrapper>());
                }
                installment = new InstallmentWrapper();
                installment.installmentNumber = Integer.ValueOf(paramBase.Installments__c);
                installment.installmentData = paramBase;
                mapBaseParam.get(groupKeySequence).add(installment);

            }
            // System.debug('mapBaseParam ==>' + JSON.serializePretty(mapBaseParam));

            Set<String> errorKeys = new Set<String>();
            for (String keyCompare : mapDeleteParam.keySet()) {
                // System.debug('keyCompare ==>' + keyCompare);

                if(mapBaseParam.containsKey(keyCompare) && mapDeleteParam.containsKey(keyCompare)){

                    List<Integer> installmentsBase =  new List<Integer>();
                    for(InstallmentWrapper deleteInstallment : mapBaseParam.get(keyCompare)){
                        installmentsBase.add(deleteInstallment.installmentNumber);
                    }
                    installmentsBase.sort();
                    // System.debug('installmentsBase before ==>' + installmentsBase);


                    List<Integer> installmentsDelete =  new List<Integer>();
                    for(InstallmentWrapper deleteInstallment : mapDeleteParam.get(keyCompare)){
                        if(installmentsBase.indexOf(deleteInstallment.installmentNumber) != -1){
                            installmentsBase.remove(installmentsBase.indexOf(deleteInstallment.installmentNumber));
                        }
                    }
                    // System.debug('installmentsBase after ==>' + installmentsBase);


                    if(installmentsBase.size() > 0){
                        if(!isSequence(installmentsBase, true)){
                            errorKeys.add(keyCompare);
                        }
                    }
                }
            }

            if(!errorKeys.isEmpty()){
                for(Parameters__c lParam :aOldLst){
                    String groupKeySequence = lParam.DefaultTargeting__c + lParam.AnatelProconProneTargeting__c + lParam.Segment__c + String.valueOf(Integer.valueOf(lParam.DebtLimitValue__c));


                    if(errorKeys.contains(groupKeySequence)){
                        // System.debug('Parametro fora da Sequencia: '+ 'groupKeySequence' + groupKeySequence +'=> Installments__c' + lParam.Installments__c);
                        lParam.addError(System.Label.Solar_Financial_ParameterMatrixErrorDeleteSequence);
                    }
                }
            }
        }
    }

    public static Boolean isSequence(List<Integer> lstValidate, Boolean validateZero){
        Boolean isSequence = true;
        Integer fistSequence = lstValidate[0];
        Integer aux = fistSequence;

        if(validateZero && fistSequence != 0){
            lastInstallmentSequence = 0;
            return false;
        }

        for (Integer indexSeq : lstValidate) {
            isSequence = (indexSeq == aux);
            if(!isSequence){
                break;
            }
            aux++;
            lastInstallmentSequence = aux;
        }
        return isSequence;
    }

    public class InstallmentWrapper {
		public Integer installmentNumber;
		public Parameters__c installmentData;
	}
}