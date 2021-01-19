/*
* Autor: RLdO
* Data: 18-out-2018
* Descrição: CEC FASE 1 COMERCIAL: classe com metodos utilitarios
*/
public with sharing class CEC_Utils {
    private static final list<Integer> LST_PESOS_CNPJ = new list<Integer>{
            6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2
    };

    // testa se o CNPJ informado eh valido
    public static Boolean validateCNPJ(String aCNPJ) {
        if (String.isBlank(aCNPJ)) return false;
        // usa um RegEx para extrair somente os digitos do CPF
        aCNPJ = aCNPJ.replaceAll('\\D', '');

        // retorna falso se numero de digitos menor que 14, ou se todos os 14 digitos sao iguais
        if ((aCNPJ.length() < 14) || (aCNPJ == aCNPJ.substring(0, 1).repeat(14))) return false;

        String lCNPJPart = aCNPJ.left(12);

        String sDV = geraDVCNPJ(lCNPJPart);
        return aCNPJ.endsWith(sDV);
    }

    // testa se o CPF informado eh valido
    public static Boolean validateCPF(String sCPF) {
        if (String.isBlank(sCPF)) return false;
        // usa um RegEx para extrair somente os digitos do CPF
        sCPF = sCPF.replaceAll('\\D', '');

        // retorna falso se numero de digitos menor que 11, ou se todos os 11 digitos sao iguais
        if ((sCPF.length() < 11) || (sCPF == sCPF.substring(0, 1).repeat(11))) return false;

        // variaveis auxiliares para calcular os DVs
        Integer dv1 = 0, dv2 = 0;

        for (Integer nCount = 0; nCount < sCPF.length() - 2; nCount++) {
            dv1 += (10 - nCount) * Integer.valueOf(sCPF.substring(nCount, nCount + 1));
            dv2 += (11 - nCount) * Integer.valueOf(sCPF.substring(nCount, nCount + 1));
        }

        dv1 = cpfcnpjCalcDV(dv1);

        dv2 = Math.mod(dv2 + (2 * dv1), 11);
        dv2 = (dv2 < 2) ? 0 : 11 - dv2;

        // sera verdadeiro se o CPF informado termina com os DVs calculados
        String sDV = String.valueOf(dv1) + String.valueOf(dv2);
        return sCPF.endsWith(sDV);
    }

    // Metodo para geracao do digito verificador de um CNPJ a partir de seus 12 primeiros digitos
    private static String geraDVCNPJ(String aCNPJ) {
        Integer dv1 = 0, dv2 = 0;
        String sDV = '';

        for (Integer nCount = 0; nCount < 12; nCount++)
            dv1 += Integer.valueOf(aCNPJ.substring(nCount, nCount + 1)) * LST_PESOS_CNPJ[nCount + 1];

        dv1 = cpfcnpjCalcDV(dv1);
        aCNPJ += String.valueOf(dv1);
        sDV += String.valueOf(dv1);

        for (Integer nCount = 0; nCount < 13; nCount++)
            dv2 += Integer.valueOf(aCNPJ.substring(nCount, nCount + 1)) * LST_PESOS_CNPJ[nCount];

        dv2 = cpfcnpjCalcDV(dv2);
        sDV += String.valueOf(dv2);
        return sDV;
    }

    private static Integer cpfcnpjCalcDV(Integer aSoma) {
        Integer lRestoDiv = Math.mod(aSoma, 11);
        return (lRestoDiv < 2) ? 0 : (11 - lRestoDiv);
    }

    public static Object navigateToField(SObject aSobj, String aRelated) {
        return navigateToField(aSobj, aRelated.split('\\.'));
    }
    public static Object navigateToField(SObject aSobj, list<String> aRelated) {
        Object lRes = null;

        try {
            SObject lSobj = aSobj;
            for (Integer i = 0; i < aRelated.size() - 1; i++) {
                lSobj = lSobj.getSObject(aRelated[i]);
            }
            lRes = lSobj.get(aRelated[aRelated.size() - 1]);
        } catch (Exception ex) {
            system.debug('RLdO navigateToField Exception ' + ex.getMessage());
            system.debug('RLdO navigateToField Exception ' + ex.getStackTraceString());
        }
        return lRes;
    }

    public static String normalizeJson(Object o) {
        return JSON.serialize(o,true).replaceAll('_Z', '').replaceAll('_z', '')
                .replaceAll('_X', '').replaceAll('_x', '');
    }

    public static String normalizeDate(String value) {
        return value.replaceAll(' ', 'T')+'-03:00';
    }
    
    
    
    public static String normalizeReturnSalesOrderMobile(String value) {
        String retorno =  value.replace('E', '').replace('.','');
        return retorno.length() > 7 ? retorno : retorno+'0';
    }
}