% 1
gcd(0, X, X) :- !.
gcd(X, 0, X) :- !.
gcd(A, B, C) :- A =< B, D is B-A, gcd(D, A, C).
gcd(A, B, C) :- A > B, D is A-B, gcd(D, B, C), !.

% 2
split([], _, [], []).
split([H1|T], H, [H1|A], B) :- H1 =< H, split(T, H, A, B).
split([H1|T], H, A, [H1|B]) :- H1 > H, split(T, H, A, B), !.

% 3
insert(E, [], [E]).
insert(E, [H|T], [E,H|T]) :- E =< H, !.
insert(E, [H|T], [H|R]) :- insert(E, T, R).

insert_sort([], []).
insert_sort([H|T], L) :- insert_sort(T, L1), insert(H, L1, L).

quick_sort([], []).
quick_sort([X], [X]).
quick_sort([H|T], L) :- split(T, H, A, B), quick_sort(A, A1), quick_sort(B, B1), append(A1, [H|B1], L), !.

% 4
queen([]).
queen([[X,Y]|S]) :- queen(S), member(Y, [1,2,3,4,5,6,7,8]), not(attack([X,Y], S)).
attack([X,Y], S) :- member([X1,Y1], S), (X = X1; Y = Y1; abs(X - X1) =:= abs(Y - Y1)).

% 5
% numbers - houses
% N - nationality
% C - house color
% P - pet
% D - drink
% S - smoke

einstein(Sol) :-
    Sol = [[1, N1, C1, P1, D1, S1],
           [2, N2, C2, P2, D2, S2],
           [3, N3, C3, P3, D3, S3],
           [4, N4, C4, P4, D4, S4],
           [5, N5, C5, P5, D5, S5]],
    member([_, british, red, _, _, _], Sol),
    member([NH, norwegian, _, _, _, _], Sol), member([BH, _, blue, _, _, _], Sol), abs(NH - BH) =:= 1,
    member([WH, _, white, _, _, _], Sol), member([GH, _, green, _, _, _], Sol), GH =:= WH - 1,
    member([_, _, green, _, coffee, _], Sol),
    member([3, _, _, _, milk, _], Sol),
    member([_, _, yellow, _, _, dunhill], Sol),
    member([_, swedish, _, dog, _, _], Sol),
    member([_, _, _, bird, _, pall_mall], Sol),
    member([MH, _, _, _, _, malboro], Sol), member([CH, _, _, cat, _, _], Sol), abs(MH - CH) =:= 1,
    member([_, _, _, _, beer, winfield], Sol),
    member([HH, _, _, horse, _, _], Sol), member([DH, _, _, _, _, dunhill], Sol), abs(HH - DH) =:= 1,
    member([_, german, _, _, _, rothman], Sol),
    member([MH, _, _, _, _, malboro], Sol), member([WH1, _, _, _, water, _], Sol), abs(MH - WH1) =:= 1.

einstein_fish(H, N, C, D, S) :- einstein(Sol), member([H, N, C, fish, D, S], Sol).

einstein_fish_all_unique(Sols) :- findall([H, N, C, D, S], einstein_fish(H, N, C, D, S), AllSols), sort(AllSols, Sols).

einstein_fish_nation