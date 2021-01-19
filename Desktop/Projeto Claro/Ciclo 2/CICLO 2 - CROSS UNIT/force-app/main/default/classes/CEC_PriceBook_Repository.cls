/**
 * Created by 93668256 on 22/11/2019.
 */

public class CEC_PriceBook_Repository extends CEC_Generic_Repository {

    public Pricebook2 getPriceBookById(String id) {
        try {
            String sql = createSelectByIdGeneric(new Pricebook2(), id);
            system.debug(sql);
            Pricebook2 pricebook2 = Database.query(sql);
            return pricebook2;
        } catch (Exception e) {
            return null;
        }
    }
}