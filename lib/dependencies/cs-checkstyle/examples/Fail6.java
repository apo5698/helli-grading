// Mistake: No at-tags on square(), no javadoc at all on main()
/**
 * Command-line utility to generate a list of squares
 *
 * @author Tyler Bletsch (tkbletsc@ncsu.edu)
 * @version 1.0
 */
public class Fail6 {
    /** Title banner for this amazing program */
    private static final String TITLE = "Awesome number square-er by Tyler Bletsch";
    
    /** We'll count up to the number */
    private static final int MAX_VALUE = 10;
    
    /**
     * Square the provided number.
     */
    private static int square(int x) {
        return x * x;
    }
    
    public static void main(String[] args) {
        System.out.println(TITLE);
        for (int i = 0; i <= MAX_VALUE; i++) {
            System.out.print(i);
            System.out.print(" ");
            System.out.println(square(i));
        }
    }
}
