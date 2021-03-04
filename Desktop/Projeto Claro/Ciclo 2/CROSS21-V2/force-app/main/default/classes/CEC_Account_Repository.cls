/**
 * Created by 93668256 on 18/11/2019.
 */

public class CEC_Account_Repository extends CEC_Generic_Repository {
    public Account getAccountById(String id) {
        try {
            String sql = createSelectByIdGeneric(new Account(), id);
            Account account = Database.query(sql);
            return account;
        } catch (Exception e) {
            return null;
        }
    }

}