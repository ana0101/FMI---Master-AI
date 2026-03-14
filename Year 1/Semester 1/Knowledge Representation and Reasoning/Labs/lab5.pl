run :-
    repeat,
    ask_questions(Facts),
    read_KB('lab5.txt', KB),
    merge_KB_and_Facts(KB, Facts, MergedKB),
    nl, writeln('--- Backward Chaining ---'),
    (
        backward_chaining(MergedKB, [pneumonia]) -> 
            true 
        ; 
            true
    ),
    nl, writeln('--- Forward Chaining ---'),
    (
        forward_chaining(MergedKB, [], [pneumonia]) -> 
            true 
        ; 
            true
    ),
    nl, writeln('Type "stop" to end or press Enter to continue: '),
    read_line_to_string(user_input, InputString),
    (
        InputString == "stop" -> 
            !               % if input is 'stop', cut and exit
        ; 
            fail            % else, repeat the process
    ).


% read clauses from a file
read_KB(File, KB) :- 
    see(File), 
    read(KB), 
    seen.


ask_questions(Facts) :-
    write('What is the temperature of the patient? (number)'), nl,
    read_line_to_string(user_input, TempStr),
    number_string(Temp, TempStr),

    write('For how many days has the patient been sick? (number)'), nl,
    read_line_to_string(user_input, DaysStr),
    number_string(DaysSick, DaysStr),

    write('Does the patient have muscle pain? (yes/no)'), nl,
    read_line_to_string(user_input, MusclePain),

    write('Does the patient have cough? (yes/no)'), nl,
    read_line_to_string(user_input, Cough),

    create_facts(Temp, DaysSick, MusclePain, Cough, Facts).


% Only create positive facts
% closed-world assumption (if a fact is not stated/derived, it is assumed to be false)
% if false facts are included, might end up with conflicts, no way to solve them

create_facts(Temp, DaysSick, MusclePain, Cough, Facts) :-
    findall(Fact, (
        (Temp >= 38 -> Fact = temperature_38 ; fail)
    ), TempFacts),
    findall(Fact, (
        (DaysSick >= 2 -> Fact = sick_2_days ; fail)
    ), SickFacts),
    findall(Fact, (
        (MusclePain == "yes" -> Fact = muscle_pain ; fail)
    ), MuscleFacts),
    findall(Fact, (
        (Cough == "yes" -> Fact = cough ; fail)
    ), CoughFacts),
    append([TempFacts, SickFacts, MuscleFacts, CoughFacts], Facts).


merge_KB_and_Facts(KB, Facts, MergedKB) :-
    findall([Fact], member(Fact, Facts), FactClauses), % convert each fact into a single-literal clause
    append(KB, FactClauses, MergedKB).


backward_chaining(_, []) :-      % if no goals left, all goals are satisfied
    writeln('YES'),
    !.

backward_chaining(KB, [Goal|RestGoals]) :-
    % writeln('Current Goal: '), writeln(Goal), nl,
    member(Clause, KB),                     % find a clause in the KB
    % writeln('Considering Clause: '), print_list(Clause), nl,
    get_positive_atom(Clause, Goal),        % check if the clause can satisfy the current goal
    % writeln('Clause can satisfy the goal.'), nl,
    findall(Atom, (member(NegAtom, Clause), NegAtom = n(Atom)), NegAtoms), % get all negative atoms from the clause
    % writeln('New Subgoals: '), print_list(NegAtoms), nl,
    append(NegAtoms, RestGoals, NewGoals),  % add negative atoms as new subgoals
    !,
    backward_chaining(KB, NewGoals).        % continue with the new goals

backward_chaining(_, _) :-
    writeln('NO'),
    fail.


get_positive_atom([H|_], H) :-
    H \= n(_), 
    !.

get_positive_atom([n(_)|T], PosAtom) :-
    get_positive_atom(T, PosAtom).


forward_chaining(_, Solved, Goals) :-
    subset(Goals, Solved),           % check if all goals are in Solved
    writeln('YES'),
    % writeln('Solved:'),
    % print_list(Solved),
    !.

forward_chaining(KB, Solved, Goals) :-
    % writeln('Current Solved: '), print_list(Solved), nl,
    select(Clause, KB, RestKB),                  % select a clause from the KB
    % writeln('Considering Clause: '), print_list(Clause), nl,
    all_negatives_solved(Clause, Solved),        % check if all negative atoms are in solved facts
    % writeln('All negatives solved for this clause.'), nl,
    get_positive_atom(Clause, PosAtom),          % get the positive atom from the clause
    \+ member(PosAtom, Solved),                  % ensure the positive atom is not already solved
    append(Solved, [PosAtom], NewSolved),        % add the positive atom to solved facts
    % writeln('New solved: '), writeln(PosAtom), nl,
    !,
    forward_chaining(RestKB, NewSolved, Goals).  % continue with the rest of the KB

forward_chaining(_, Solved, _) :-
    writeln('NO'),
    % writeln('Solved:'),
    % print_list(Solved),
    fail.


all_negatives_solved([n(H)|T], Solved) :-
    member(H, Solved),
    all_negatives_solved(T, Solved).

all_negatives_solved([H|T], Solved) :-
    H \= n(_),
    all_negatives_solved(T, Solved).

all_negatives_solved([], _).


print_list([]).
print_list([H|T]) :-
    write(H), nl,
    print_list(T).



% Rules
pneumonia :- cough, infection.
fever :- temperature(T), T >= 38.
flu :- muscle_pain, fever.
infection :- days_sick(D), D >= 2, fever.

% Facts
temperature(39).
days_sick(1).
muscle_pain :- fail.
cough :- fail.