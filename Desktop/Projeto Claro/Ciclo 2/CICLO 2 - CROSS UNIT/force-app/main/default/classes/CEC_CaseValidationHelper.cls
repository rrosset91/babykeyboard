/*
* Autor: Squad Canais Criticos - Sysmap
* Data: 14/07/2020
* Description: Validação de informações de caso que não podem ser feitas via Validation Rules
* ---------------------------------------------------------------
*/
public without sharing class CEC_CaseValidationHelper 
{
    /*
     * Error message to use in the newCase.addError
     */
    public static final String VALIDATION_MESSAGE = 'Não é possível alterar a descrição do caso.';
    
    /*
     * Map of special characteres
     */
    @TestVisible
    private static final Map<String,String> SPECIAL_CHARACTERS = new Map<String,String> {
    	'\u2028' => '\\n'
    };
    
    //List of recordTypes
    private static Set<ID> RECORD_TYPES_DESCRIPTION_VALIDATION;
    
    /*
     *  Get the list of recordTypes for the description validation
	 */
    @TestVisible
    private static Set<ID> getRecordTypesDescriptionValidation() {
        if(RECORD_TYPES_DESCRIPTION_VALIDATION == null) {
            Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
            RECORD_TYPES_DESCRIPTION_VALIDATION = new Set<ID>();
            if(caseRecordTypes.containsKey('Consumidor_GOV')) {
        		RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('Consumidor_GOV').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_Anatel')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_Anatel').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_AtendimentoPessoal')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_AtendimentoPessoal').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_Canais_Eletronicos')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_Canais_Eletronicos').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_CanaisInternos')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_CanaisInternos').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_JEC')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_JEC').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_Ouvidoria')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_Ouvidoria').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_Pre_JEC')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_Pre_JEC').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_Procon')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_Procon').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_ReaberturaAnatel')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_ReaberturaAnatel').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('CEC_CC_SuporteApoio')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('CEC_CC_SuporteApoio').getRecordTypeId());    
            }
            if(caseRecordTypes.containsKey('ChildrenCases')) {
                RECORD_TYPES_DESCRIPTION_VALIDATION.add(caseRecordTypes.get('ChildrenCases').getRecordTypeId());    
            }
        }
        return RECORD_TYPES_DESCRIPTION_VALIDATION;
    }
    
    /*
     *  Method to validade the change of the description of some recordTypes
     *  @return list of invalid Case
     */
    public static List<Case> validateChangeDescription(List<Case> oldCases, List<Case> newCases) {
        return validateChangeDescription(oldCases, newCases, true, true);
    }

	/*
	 * Replace the description, removing the special character from the old and new value 
	 */    
    private static String[] formatDescription(String characterKey, String oldDescription, String newDescription) {
        
        if(oldDescription != null && oldDescription.contains(characterKey)) {
            
            System.debug(String.format('CEC_CaseValidationHelper.formatDescription -> Encontrado caracteres especial na verificacao de descricao. Valor do banco => {0}, Valor da interface => {1}',new String[] {oldDescription,newDescription})); 
            
            String characterValue = SPECIAL_CHARACTERS.get(characterKey);
            
            //Remove the character from the old value, using the key. Must remove the value also in case of the the user type the value in the description
            oldDescription = oldDescription.replaceAll(characterKey,''); //use the replaceAll because is a regex
            oldDescription = oldDescription.replace(characterValue,'');
            
            //Remove the value from the new value
            newDescription = newDescription.replaceAll(characterKey,''); //use the replaceAll because is a regex
            newDescription = newDescription.replace(characterValue,'');                               
        }
        
        return new String[] {oldDescription,newDescription};        
    }

    /**
     * Check is some values are equals, ignoring spaces
     */
    private static boolean isEquals(String oldValue, String newValue) {

        if(oldValue == null) {
            oldValue = '';
        } else {
            oldValue = oldValue.normalizeSpace();
        }

        if(newValue == null) {
            newValue = '';
        } else {
            newValue = newValue.normalizeSpace();
        }

        Boolean equals = oldValue.equals(newValue);

        if(!equals) {

            System.debug('CEC_CaseValidationHelper.validateChangeDescription -> Valores distintos. Valores formatados testados, antigo e novo.');
            System.debug(oldValue);
            System.debug(newValue);

        }

        return equals;
    }
    
    /**
     *  Method to validade the change of the description of some recordTypes
     *  @return list of invalid Case
     */
    public static List<Case> validateChangeDescription(List<Case> oldCases, List<Case> newCases, boolean validateRecordTypes, boolean setErrorInCases) {
        List<Case> invalidCases = new List<Case>();
        
        if(oldCases != null && !oldCases.isEmpty() &&
           newCases != null && !newCases.isEmpty() &&
           oldCases.size() == newCases.size()) {
               
           Set<ID> recordTypes = validateRecordTypes ? getRecordTypesDescriptionValidation() : null;

           for(Integer i = 0; i < oldCases.size(); i++) {
                
                Case oldCase = oldCases.get(i);
                Case newCase = newCases.get(i);
                   
                //Just validate de description if the recordType of the record is in the list
                if(!validateRecordTypes || (recordTypes != null && recordTypes.contains(newCase.RecordTypeId))) {
                       
                    String oldDescription = oldCase.Description != null ? oldCase.Description.trim() : '';
                    String newDescription = newCase.Description != null ? newCase.Description.trim() : '';
                    
                    String oldRequestSupport = oldCase.RequestSupport__c != null ? oldCase.RequestSupport__c.trim() : '';
                    String newRequestSupport = newCase.RequestSupport__c != null ? newCase.RequestSupport__c.trim() : '';
                      
                    //If the description contains a special character, replace the caracter
                    for(String characterKey : SPECIAL_CHARACTERS.keySet()) {
                        
                        //Format for the description
                        String[] formattedValues = formatDescription(characterKey, oldDescription, newDescription);
                        oldDescription = formattedValues[0];
                        newDescription = formattedValues[1];

                        //Format for the requestSupport
                        formattedValues = formatDescription(characterKey, oldRequestSupport, newRequestSupport);
                        oldRequestSupport = formattedValues[0];
                        newRequestSupport = formattedValues[1];

                    }
                       
                    //Compare the two values
                    if(!isEquals(oldDescription, newDescription) || !isEquals(oldRequestSupport, newRequestSupport)) {
                            
                        System.debug('CEC_CaseValidationHelper.validateChangeDescription -> Encontrada diferenca entre a descricao do caso ou entre o request support. Valores abaixo na sequencia: oldDescription, newDescription, oldRequestSupport e newRequestSupport');
                        System.debug(oldDescription);
                        System.debug(newDescription);
                        System.debug(oldRequestSupport);
                        System.debug(newRequestSupport);
                         
                        if(setErrorInCases) {                           

                            newCase.addError(VALIDATION_MESSAGE);                               

                        }  
                           
                        invalidCases.add(newCase);
                   }                        
                }                   
            }
        }
        return invalidCases;
    }      
}