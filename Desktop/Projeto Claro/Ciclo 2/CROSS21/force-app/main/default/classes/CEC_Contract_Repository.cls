/**
 * Created by 93668256 on 21/11/2019.
 */

public class CEC_Contract_Repository extends CEC_Generic_Repository {
    public Contract getContractById(String id) {
        try {
            String sql = createSelectByIdGeneric(new Contract(), id);
            Contract Contract = Database.query(sql);
            return Contract;
        } catch (Exception e) {
            return null;
        }
    }
}