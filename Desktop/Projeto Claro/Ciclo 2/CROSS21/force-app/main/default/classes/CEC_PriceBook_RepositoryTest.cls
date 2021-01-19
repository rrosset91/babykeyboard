@isTest
public class CEC_PriceBook_RepositoryTest {

    @isTest
    public static void mainTest() {
        new CEC_PriceBook_Repository().getPriceBookById(test.getStandardPricebookId());
    }
}