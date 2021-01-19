/**
 * Created by 93668256 on 18/11/2019.
 */

public class CEC_User_Repository extends CEC_Generic_Repository {

    public User getUserById(String id) {
        try {
            String sql = 'select Id,Claro__c,Name,CPF__c,Email,Phone,CEC_SalesAgent__c,CompanyName,Channel__c, ProfileId, ' +
                    'CEC_Regional__c, IsActive, LastModifiedDate from user where id=' + '\'' + id + '\'';
            system.debug(sql);
            User user = Database.query(sql);

            return user;
        } catch (Exception e) {
            return null;
        }
    }

    public Profile getProfileByUserId(String id) {
        String sql = createSelectByIdGeneric(new Profile(), id);
        Profile profile = Database.query(sql);

        return profile;
    }
}