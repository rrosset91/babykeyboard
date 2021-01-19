/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe de apoio que contém algumas funcionalidades genéricas, tal como o script de validação do dígito verificador de CNPJ.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
public with sharing class CEC_PME_Utils {
	private CEC_PME_Utils(){}
	
	public static Boolean validateCNPJ(String cnpj){

	// considera-se erro CNPJ's formados por uma sequencia de numeros iguais
    if ('00000000000000'.equals(cnpj) || '11111111111111'.equals(cnpj) ||
        '22222222222222'.equals(cnpj) || '33333333333333'.equals(cnpj) ||
        '44444444444444'.equals(cnpj) || '55555555555555'.equals(cnpj) ||
        '66666666666666'.equals(cnpj) || '77777777777777'.equals(cnpj) ||
        '88888888888888'.equals(cnpj) || '99999999999999'.equals(cnpj) ||
       (cnpj.length() != 14))
 
       return false;
 
	Integer sm, i, r, num, peso, dig13, dig14;
    List<String> cnpjString = CNPJ.split('');
    sm = 0;
    peso = 2;
    for (i=11; i>=0; i--) {
        num = Integer.valueOf(cnpjString[i]);
        sm = sm + (num * peso);
        peso = peso + 1;
        if (peso == 10)
           peso = 2;
    }
 
    r = math.mod(sm, 11);
    if ((r == 0) || (r == 1))
         dig13 = 0;
    else dig13 = Integer.valueOf(11-r);
 
	//Calculo do 2o. Digito Verificador
    sm = 0;
    peso = 2;
    for (i=12; i>=0; i--) {
        num = Integer.valueOf(cnpjString[i]);
        sm = sm + (num * peso);
        peso = peso + 1;
        if (peso == 10)
           peso = 2;
    }
 
    r = math.mod(sm, 11);
    if ((r == 0) || (r == 1))
        dig14 = 0;
    else dig14 = Integer.valueOf(11-r);
 
	// Verifica se os dígitos calculados conferem com os dígitos informados.
        if (dig13 == Integer.valueOf(cnpjString[12]) && dig14 == Integer.valueOf(cnpjString[13]))
        return true;
    else 
    	return false ;
    
	}

	public static boolean validateCPF(String CPF) {
       System.debug('valida cnpj false');
        if (CPF.equals('00000000000') || CPF.equals('11111111111') ||
            CPF.equals('22222222222') || CPF.equals('33333333333') ||
            CPF.equals('44444444444') || CPF.equals('55555555555') ||
            CPF.equals('66666666666') || CPF.equals('77777777777') ||
            CPF.equals('88888888888') || CPF.equals('99999999999') ||
           (CPF.length() != 11))
           return(false);
    
        Integer dig10, dig11, sm, i, r, num, peso;
     
           
          sm = 0;
          peso = 10;
          List<String> cpfString = cpf.split('');
          for (i=0; i<9; i++) {
            num = Integer.valueOf(cpfString[i]); 
            sm = sm + (num * peso);
            peso = peso - 1;
          }
    
          r = 11 - (math.mod(sm,11));
          if ((r == 10) || (r == 11))
             dig10 = 0;
          else dig10 = r;
    
        // Calculo do 2o. Digito Verificador
          sm = 0;
          peso = 11;
          for(i=0; i<10; i++) {
            num = Integer.valueOf(cpfString[i]);
            sm = sm + (num * peso);
            peso = peso - 1;
          }
    
          r = 11 - (math.mod(sm,11));
          if ((r == 10) || (r == 11))
             dig11 = 0;
          else dig11 = r;
    
        // Verifica se os digitos calculados conferem com os digitos informados.
          if (dig10 == Integer.valueOf(cpfString[9]) && dig11 == Integer.ValueOf(cpfString[10]))
             return true;
          else return false;
      }
    
    public static String[] searchInApexClasses(String searchTerm) {
        ApexClass[] apxcList = [SELECT Name, Body FROM ApexClass];
        String[] results = new List<String>();
        
        for (ApexClass apxc : apxcList) {
            if ('(hidden)'.equals(apxc.Body)) {
                continue;
            }
            if (apxc.Body.contains(searchTerm)) {
                results.add(apxc.Name);
            }
        }
        
        return results;
    }

}