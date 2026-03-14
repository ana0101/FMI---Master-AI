sat(File) :-
    read_clauses(File, Clauses),
    (   dp(Clauses, Solution) ->  
            writeln('YES'),
            writeln('Solution:'),
            print_solution(Solution)
    ;   
        writeln('NOT')
    ).


print_solution([]).
print_solution([C/A | Rest]) :-
    literal_value(C, A, Atom, Value),
    write(Atom), write(' = '), write(Value), nl,
    print_solution(Rest).

% duplicatesetermine the actual atom and its Boolean value
literal_value(n(C), true, C, false).   % n(C) is true → C = false
literal_value(n(C), false, C, true).   % n(C) is false → C = true
literal_value(C, true, C, true).       % C is true → C = true
literal_value(C, false, C, false).     % C is false → C = false


% read clauses from a file
read_clauses(File, Clauses) :- 
    see(File), 
    read(Clauses), 
    seen.


dp([], []).
dp(L, _) :- member([], L), !, fail.

% ; is the logical OR operator in Prolog
% if assigning C to true leads to a solution, then it does not continue to try assigning C to false
% if assigning C to true fails, then it tries assigning C to false

dp(L, [C/A | S]) :- 
    choose_atom_most_frequent(L, C),
    (   A = true,
        simplify(L, C, true, L1),
        dp(L1, S)
    ; 
        A = false,
        simplify(L, C, false, L2),
        dp(L2, S)
    ).


% choose a unit clause if there is one
choose_atom_unit_first(L, C) :-
    member([Lit], L),
    positive_literal(Lit, C), !.

% otherwise, choose the first atom from the first clause
choose_atom_unit_first([[Lit|_]|_], C) :-
    positive_literal(Lit, C).

% choose the most frequent atom from CNF
choose_atom_most_frequent(L, C) :-
    % 1. Collect all atoms (positive form)
    findall(Atom, (member(Clause, L), member(Lit, Clause), positive_literal(Lit, Atom)), Atoms),
    % 2. Sort atoms to group duplicates
    msort(Atoms, Sorted),
    % 3. Count occurrences of each atom
    count_atoms(Sorted, Counts),
    % 4. Find the atom with maximum count
    max_count_atom(Counts, C/_).

% count_atoms(+SortedAtoms, -Atom-CountList)
count_atoms([], []).
count_atoms([H|T], [H/Count|RestCounts]) :-
    count_same(H, [H|T], Count, Remaining),
    count_atoms(Remaining, RestCounts).

% count_same(+Atom, +List, -Count, -Remaining)
count_same(_, [], 0, []).
count_same(H, [H|T], N, Rest) :-
    count_same(H, T, N1, Rest),
    N is N1 + 1.
count_same(H, [X|T], 0, [X|T]) :-
    H \= X.

% find the atom with the maximum count
max_count_atom([A/C], A/C).
max_count_atom([A1/C1, A2/C2 | T], Max) :-
    (C1 >= C2 -> max_count_atom([A1/C1|T], Max)
    ; max_count_atom([A2/C2|T], Max)
    ).
    

% get the positive
positive_literal(C, C).
positive_literal(n(C), C).


% the . procedure
simplify([], _, _, []).

% if C is true
% remove all clauses that contain C (since they are satisfied)
% remove n(C) from all remanining clauses (since n(C) is false and will be useless)

simplify([Clause | Rest], C, true, Result) :-
    (   member(C, Clause) ->
            simplify(Rest, C, true, Result)
        ;
            remove(n(C), Clause, NewClause),
            simplify(Rest, C, true, NewRest),
            Result = [NewClause | NewRest]
    ).

% if C is false
% remove all clauses that contain n(C) (since they are satisfied)
% remove C from all remanining clauses (since C is false and will be useless)

simplify([Clause | Rest], C, false, Result) :-
    (member(n(C), Clause) ->
        simplify(Rest, C, false, Result)
    ;
        remove(C, Clause, NewClause),
        simplify(Rest, C, false, NewRest),
        Result = [NewClause | NewRest]
    ).


% remove C from a clause
remove(_, [], []).
remove(C, [C|T], R) :- remove(C, T, R), !.
remove(C, [H|T], [H|R]) :- remove(C, T, R).