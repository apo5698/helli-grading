/**
 * Command-line utility to generate a list of squares
 *
 * @author Tyler Bletsch (tkbletsc@ncsu.edu)
 * @version 1.0
 */
public class Various 
{
    /** Title banner for this amazing program */
    private static final String TITLE = "Awesome number square-er by Tyler Bletsch";
    
    /** We'll count up to the number */
    private static final int MAX_VALUE = 10;
    
    /**
     * Square the provided number.
     * @param x  The number to square.
     * @return   The square of the given number.
     */
    private static int square (int x) 
    {
        return x * x;
    }
    
    /**
     * Executed at program launch, prints the squares of integers 0..MAX_VALUE.
     * @param args  Command line arguments, ignored.
     */
    public static void main (String[]args) throws IOException {
        System.out.println(TITLE);
        for (int i = 0; i <= MAX_VALUE; i++) {
            System.out.print(i);
            System.out.print(" ");
            System.out.println(square(i));
        }
        for(int i = 0; i < 5; i++) {}
        if (1 == 1) 
            System.out.println("One line ifs are dumb + scary.");
        while (1 == 0) 
            System.out.println("One line whiles are even more-so.");
    }
}
