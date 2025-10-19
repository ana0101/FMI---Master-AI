% 1
max(X, Y, X) :- X >= Y.
max(X, Y, Y) :- X < Y.

% 2
member(E, [E|_]).
member(E, [_|T]) :- member(E, T).

concat([], L, L).
concat([H|T], L, [H|R]) :- concat(T, L, R).

% 3
% alt_sum(L, S) = a0 - a1 + a2 - a3 + ...
% face cate 2 deodata
alt_sum([], 0).
alt_sum([H], H).
alt_sum([H1, H2|T], S) :- alt_sum(T, S1), S is H1 - H2 + S1.

% 4
elim_one(_, [], []).
elim_one(E, [E|T], T) :- !.
elim_one(E, [H|T], [H|R]) :- elim_one(E, T, R).

elim_all(_, [], []).
elim_all(E, [E|T], R) :- !, elim_all(E, T, R).
elim_all(E, [H|T], [H|R]) :- elim_all(E, T, R).

% 5
reverse([], []).
reverse([H|T], R) :- reverse(T, RT), concat(RT, [H], R).

% select(E, L, R) - selects element E from list L, leaves R as the remaining list
select(E, [E|T], T).
select(E, [H|T], [H|R]) :- select(E, T, R).

perm([], []).
perm(L, [H|T]) :- select(H, L, R), perm(R, T).

% 6
% count(E, L, N) - N is the number of times element E appears in list L
count(_, [], 0).
count(E, [E|T], N) :- !, count(E, T, M), N is M+1.
count(E, [_|T], N) :- count(E, T, N).

% 6) count occurrences of element in list
% count(E, List, N)
count(E, L, N) :- count_acc(L, E, 0, N).

count_acc([], _, Acc, Acc).
count_acc([H|T], E, Acc, N) :-
    ( H = E ->
        Acc1 is Acc + 1
    ;
        Acc1 is Acc
    ),
    count_acc(T, E, Acc1, N).

% 7) insert element E at position Pos (1-based) into List -> Result
% If Pos = 1 insert at head. If Pos > length+1, predicate will insert at end.
insert_at(E, 1, L, [E|L]) :- !.
insert_at(E, Pos, [], [E]) :-
    Pos > 1, !.
insert_at(E, Pos, [H|T], [H|R]) :-
    Pos > 1,
    P1 is Pos - 1,
    insert_at(E, P1, T, R).

% 8) merge/3 two ascending ordered lists (result ascending)
merge_sorted([], L, L).
merge_sorted(L, [], L).
merge_sorted([H1|T1], [H2|T2], [H1|R]) :-
    H1 =< H2,
    merge_sorted(T1, [H2|T2], R).
merge_sorted([H1|T1], [H2|T2], [H2|R]) :-
    H1 > H2,
    merge_sorted([H1|T1], T2, R).
