package resolutiontp;

import java.util.Arrays;
import java.util.Comparator;
import java.util.Scanner;
import java.util.TreeSet;

/**
 *
 * @author Jon Cohen
 * 
 * Uses resolution to show whether or not a clause set is satisfiable.
 * Tree sets are used for clause sets with comparison by size first, then lexicographically.
 * This has a few advantages.  First, if the empty clause is present, it is always first 
 * in the set.  Second, this allows us to resolve on smaller clauses first, a 
 * good heuristic for speeding up runtime.  This is potentially a huge performance
 * gain with easy code and not much overhead over a regular hash set, unless the 
 * clause set is enormous.  It also allows us to use the ordering to cut the number
 * of loops in half during the algorithm and during subsumption testing.
 * 
 * The typical use-case for this program would be to input a knowledge base followed
 * by the negation of some logical sentence for which the user would like to either
 * prove or find unsatisfiable.  The sentence is attempted to be proven by contradiction
 * using the resolution rule.
 * 
 * This assignment was completed with Danny Kotson.
 */
public class ResolutionTP {
    TreeSet<TreeSet<String>> clauseSet;
    TreeComp compare = new TreeComp();
    
    /**
     * Reads a list of logical clauses from standard input and then prunes the input
     * using the subsumption heuristic.
     * Clauses should be space-separated strings, with a tilde (~) representing
     * the logical negation of a literal. (eg, A B ~C)
     */
    public ResolutionTP() {
        Scanner in = new Scanner(System.in);
        String line;
        TreeSet<String> clause;
        
        clauseSet = new TreeSet(compare);
        while(in.hasNextLine()) {
            line = in.nextLine();
            if (line.equals("end")) {
                break;
            }
            clause = new TreeSet();
            clause.addAll(Arrays.asList(line.split(" ")));
            clauseSet.add(clause);
        }
        clauseSet = subsumption(clauseSet);
    }
    
    //Java doesn't like having a singe clauseSetUnion method returning a TreeSet.
    //It's simple enough that these two are left separate for now just to move on.
    private TreeSet<TreeSet<String>> clauseSetUnion(TreeSet<TreeSet<String>> set1, TreeSet<TreeSet<String>> set2) {
        TreeSet<TreeSet<String>> union  = new TreeSet(compare);
        union.addAll(set1);
        union.addAll(set2);
        return union;
    }
    
    private TreeSet clauseUnion(TreeSet<String> set1, TreeSet<String> set2) {
        TreeSet<String> union = new TreeSet();
        union.addAll(set1);
        union.addAll(set2);
        return union;
    }
    
    /* 
     * Returns true if the given set of clauses contains the empty set.
     * Because the set is ordered, and the empty set is minimal, we need only
     * to check the first element in the Set.
    */
    private boolean containsBox(TreeSet<TreeSet<String>> clauseSet) {
        return clauseSet.first().isEmpty();
    }
    
    private String not(String literal) {
        return (literal.charAt(0) == '~') ? literal.substring(1) : '~' + literal;
    }
    
    //Resolves two clause sets on a given literal
    private TreeSet<String> resolveOn(String literal, TreeSet<String> set1, TreeSet<String> set2) {
        TreeSet<String> res = clauseUnion(set1, set2);
        if (res.remove(not(literal))) {
            res.remove(literal);
        }       
        return res;
    }
    
    private TreeSet<TreeSet<String>> resolvents(TreeSet<String> set1, TreeSet<String> set2) {
        TreeSet<TreeSet<String>> resolvents = new TreeSet(compare);
        for (String literal : set1) {
            resolvents.add(resolveOn(literal, set1, set2));
        }
        return resolvents;
    }
    
    private TreeSet difference(TreeSet left, TreeSet right) {
        left.removeAll(right);
        return left;
    }
    
    private TreeSet<TreeSet<String>> subsumption(TreeSet<TreeSet<String>> clauseSet) {
        TreeSet<TreeSet<String>> toRemove = new TreeSet(compare);
        for (TreeSet<String> clause : clauseSet) {
            for (TreeSet<String> biggerClause : clauseSet.tailSet(clause, false)) {
                if (biggerClause.containsAll(clause)) {
                    toRemove.add(biggerClause);
                }
            }
        }
        clauseSet.removeAll(toRemove);
        return clauseSet;
    }
    
    /**
     * 
     * @return true if the clause set represented by this ResolutionTP object is satisfiable, and false otherwise
     */
    public boolean isSatisfiable() {
        TreeSet<TreeSet<String>> old = new TreeSet(compare),res, newest;
        while (true) {
            newest = new TreeSet(compare);
            for (TreeSet<String> x : clauseSet) {
                for (TreeSet<String> y : clauseSet.tailSet(x, false)) {
                    res = resolvents(x, y);
                    if(containsBox(res)) {
                        return false;
                    }
                    newest = clauseSetUnion(newest, difference(res, clauseSetUnion(old, clauseSet)));                    
                }
                for (TreeSet<String> y : old) {
                    res = resolvents(x, y);
                    if(containsBox(res)) {
                        return false;
                    }
                    newest = clauseSetUnion(newest, difference(res, clauseSetUnion(old, clauseSet)));
                }
            }
            
            newest = subsumption(newest);
            if (newest.isEmpty()) {
                return true;
            }
            
            old = clauseSetUnion(old, clauseSet);
            old = subsumption(old);
            clauseSet = newest;
        }
    }
    
    public static void main(String[] args) {
        ResolutionTP testRes = new ResolutionTP();
        System.out.println(testRes.isSatisfiable() ? "Satisfiable" : "Unsatisfiable");
    }
}

class TreeComp implements Comparator<TreeSet<String>> {
    /*
     * The ordering here is that smaller trees are less than bigger trees.
     * Between trees of the same size, their contents are concatenated and then compared
     * lexicographically.
     */
    @Override
    public int compare(TreeSet<String> left, TreeSet<String> right) {
        if (left.size() != right.size()) {
            return left.size() < right.size() ? -1 : 1;
        }
        return left.toString().compareTo(right.toString()); //This works because these are ordered trees.
    }
}