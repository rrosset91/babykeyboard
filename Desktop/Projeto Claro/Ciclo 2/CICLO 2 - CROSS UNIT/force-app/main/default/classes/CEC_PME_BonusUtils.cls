/*

* Autor: Argenis Cortez - Aconcagua Team

* Data: 18/10/2019

* Descrição: Classe de regras de negócio do objeto Bonus__c

*/

global class CEC_PME_BonusUtils implements vlocity_cmt.VlocityOpenInterface {
	private Map<String, Object> input;
	private Map<String, Object> output;
	private Map<String, Object> options;


/*

* Autor: Argenis Cortez - Aconcagua Team

* Data: 18/10/2019

* Descrição: Método abstrato da interface de Vlocity

*/
    
	global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
		try {
			System.debug('input: ' + JSON.serialize(input));
			System.debug('output: ' + JSON.serialize(output));
			System.debug('options: ' + JSON.serialize(options));
			this.input = input;
			this.output = output;
			this.options = options;

			switch on methodName {
                when 'getBonusByType' {
                    this.getBonusByType();
                }
                when 'getBonusKit' {
                    this.getBonusKit();
                }
               
              }
            } catch (Exception ex) {
			      throw ex;
		      }
         return true;
	   }
    
    /*

* Autor: Argenis Cortez - Aconcagua Team

* Data: 18/10/2019

* Descrição: Método de pesquisa de Bonus by Type

*/
    
    private void getBonusByType() {
        try {
            Boolean convergencia = (Boolean)this.options.get('Convergencia');
            String typeB = String.valueOf(this.options.get('Type'));
            String productId = String.valueOf(this.options.get('ProductId'));
            Date data = Date.today();
            
			List<Bonus__c> Bonus =[SELECT tipo_bonus__c,Bonus__c FROM Bonus__c WHERE (Produto__c = :productId AND ( (End_Date__c = null AND Start_Date__c <= :data) OR (End_Date__c > :data AND Start_Date__c <= :data) OR (End_Date__c > :data AND Start_Date__c = null) ))];          
            List<Bonus_Type_PME__mdt> BonusType = [SELECT id,type__c,convergence__c,priority__c,bonus_type__c FROM Bonus_Type_PME__mdt WHERE (Convergence__c = :convergencia AND Type__c = :typeB) ORDER BY Priority__c ASC];
            System.debug('BONUSLIST:'+Bonus);
            System.debug('BONUSTYPELIST:'+BonusType);
            
            output.put('Bonus',null);
            
            for(Bonus_Type_PME__mdt obj:BonusType)
            {
               String typeBonus = obj.bonus_type__c;
                                    
                for(Bonus__c bonusObj:Bonus)
                {
                    String bt = bonusObj.tipo_bonus__c;
                    System.debug('TYPE:'+typeBonus + ' BONUS:'+bt);

                    if(typeBonus.equals(bt))
                    {
                        output.put('Bonus',bonusObj.Bonus__c);
                        return;
                    }
                }
                
            }
            
            
            
            
            }
        catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
	 }


     private void getBonusKit() {
        try {
            
            
            List<Object>franquias = (List<Object>)options.get('Franquias');
            List<Object>franquiasConBonus = new List<Object>();

            for(Object fran:franquias)
            {
            Map<String,Object>franquia = (Map<String,Object>)fran;
       
            Boolean convergencia = (Boolean)franquia.get('Convergencia');
            String typeB = String.valueOf(franquia.get('SelectTSolicitacao'));
            String productId = String.valueOf(franquia.get('ProductId'));
            Date data = Date.today();

            System.debug('Convergencia:'+convergencia);
            System.debug('Solicitacao:'+typeB);
            System.debug('ProductId:'+productId);

            
			List<Bonus__c> Bonus =[SELECT tipo_bonus__c,Bonus__c FROM Bonus__c WHERE (Produto__c = :productId AND ( (End_Date__c = null AND Start_Date__c <= :data) OR (End_Date__c > :data AND Start_Date__c <= :data) OR (End_Date__c > :data AND Start_Date__c = null) ))];          
            List<Bonus_Type_PME__mdt> BonusType = [SELECT id,type__c,convergence__c,priority__c,bonus_type__c FROM Bonus_Type_PME__mdt WHERE (Convergence__c = :convergencia AND Type__c = :typeB) ORDER BY Priority__c ASC];
            franquia.put('Bonus',null);
            for(Bonus_Type_PME__mdt obj:BonusType)
            {
               String typeBonus = obj.bonus_type__c;
                                    
                for(Bonus__c bonusObj:Bonus)
                {
                    String bt = bonusObj.tipo_bonus__c;
                    System.debug('TYPE:'+typeBonus + ' BONUS:'+bt);

                    if(typeBonus.equals(bt))
                    {
                        franquia.put('Bonus',bonusObj.Bonus__c);
                        continue;        
                    }
                }
                
            }
                        
            }
            output.put('Franquias',franquias);
        }
        catch(Exception e) {
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
	 }



    }