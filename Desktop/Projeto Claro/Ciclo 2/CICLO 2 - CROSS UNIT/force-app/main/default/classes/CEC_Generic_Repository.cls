/**
 * Created by 93668256 on 18/11/2019.
 */

public abstract class CEC_Generic_Repository {

    public String createSelectAllGeneric(sObject o) {
        Map<String, Schema.SObjectField> fieldMap = o.getsObjectType().getDescribe().fields.getMap();

        String fieldNames = '';
        for (String s : fieldMap.keySet())
            fieldNames += s + ', ';

        String retorno = 'select ' + fieldNames.substring(0, fieldNames.lastIndexOf(',')) + ' from ' + o.getsObjectType();

        return retorno;
    }

    public String createSelectByIdGeneric(sObject o, String id) {
        return createSelectAllGeneric(o) + ' where id = '+concatString(id);
    }

    public String concatString(String value){
        return '\'' + value + '\'';
    }


}