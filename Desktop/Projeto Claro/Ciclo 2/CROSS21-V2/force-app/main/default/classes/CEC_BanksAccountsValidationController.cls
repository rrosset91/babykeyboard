/**
 * Created by 93668256 on 04/12/2019.
 */

global with sharing class CEC_BanksAccountsValidationController implements vlocity_cmt.VlocityOpenInterface {

    private final CEC_IntegrationBanksAccountsValidation integration = new CEC_IntegrationBanksAccountsValidation();

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (methodName.equalsIgnoreCase('banksAccountsValidation'))
                return executeValidation(inputMap, outMap);
            else
                    return false;
        } catch (Exception e) {
            system.debug(e.getMessage());
            return false;
        }
    }

    global Boolean executeValidation(Map<String, Object> inputMap, Map<String, Object> outMap) {
        Boolean retorno = integration.isAccountValid((String) inputMap.get('bic'),(String) inputMap.get('branchNumber'),(String) inputMap.get('accountNumber'));
        outMap.put('isAccountValid', retorno);
        return true;
    }

}