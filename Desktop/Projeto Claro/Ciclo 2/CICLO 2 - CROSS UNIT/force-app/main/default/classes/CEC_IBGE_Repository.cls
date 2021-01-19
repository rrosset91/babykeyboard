/**
 * Created by 93668256 on 09/12/2019.
 */

public class CEC_IBGE_Repository extends CEC_Generic_Repository{

    public IBGE__c getIBGEByCityNameAndDD(String cityName, String uf) {
        try {
            String sql = 'select UF__c, IBGECode__c FROM IBGE__c where CityName__c='+concatString(cityName)+
                    ' and UF__c= ' +concatString(uf);

            IBGE__c ibge = Database.query(sql);
            return ibge;
        } catch (Exception e) {
            return null;
        }
    }

}