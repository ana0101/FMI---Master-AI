% read clauses from a file
read_clauses(File, Clauses) :- 
    see(File), 
    read(Clauses), 
    seen.

% main resolution
% if an empty clause is found in KB, then KB is unsatisfiable

res(KB) :-
    sortKB(KB, SKB),    % sort KB (when checking member, [a,b] and [b,a] are considered different)
    resSorted(SKB).

resSorted(KB) :- 
    member([], KB), 
    !, 
    write('UNSATISFIABLE'), 
    nl.

resSorted(SKB) :- 
    member_with_rest(C1, Rest, SKB),    % choose first claus   
    member(C2, Rest),                   % choose second clause
    C1 \== C2,                          % make sure it is not the same clause
    resolve(C1, C2, Resolvent),         % resolve them (with unification and variable renaming)
    \+ member(Resolvent, SKB),          % if the resolvent is not already in SKB
    \+ tautology(Resolvent),            % and is not a tautology
    append(SKB, [Resolvent], NewSKB),   % add the resolvent to SKB
    !,                                  % cut here to avoid trying all possible pairs of clauses
    resSorted(NewSKB).                  % continue resolution with the new SKB

resSorted(_) :-
    write('SATISFIABLE'), 
    nl.

% sort clauses in KB
sortKB([], []).
sortKB([C|T], [SC|ST]) :-
    sort(C, SC),
    sortKB(T, ST).

% member predicate that also returns the rest of the list
% used to not pick the same pair of clauses again
member_with_rest(X, Rest, [X|Rest]).
member_with_rest(X, Rest, [_|Tail]) :-
    member_with_rest(X, Rest, Tail).

% check if a clause has both a literal and its negation
tautology(Clause) :-
    member(Lit, Clause),
    negate(Lit, NegLit),
    member(NegLit, Clause).

% resolve two clauses
% In first-order logic, we must:
%   - rename variables in each clause so they do not interfere
%   - find two complementary literals that can be unified
%   - apply the resulting substitution
resolve(C1, C2, Resolvent) :- 
    copy_term((C1, C2), (C1Copy, C2Copy)),     % rename variables apart (standardize apart)
    member(Lit1, C1Copy),                      % go over literals in C1
    negate(Lit1, NegLit1),                     % negate it
    member(Lit2, C2Copy),                      % check literals in C2
    unify_with_occurs_check(NegLit1, Lit2),    % try to unify complementary literals
    delete(C1Copy, Lit1, C1R),                 % remove resolved literal from C1
    delete(C2Copy, Lit2, C2R),                 % remove resolved literal from C2
    append(C1R, C2R, Resolvent1),              % combine what remains from both clauses
    sort(Resolvent1, Resolvent).               % sort to avoid duplicates

% negate a literal
negate(n(X), X) :- !.
negate(X, n(X)).
