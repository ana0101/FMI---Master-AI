% Degree curves

% Service

poor(X,Y) :- X =< 0, Y is 1.
poor(X,Y) :- X > 0, X < 3, Y is (3-X)/3.
poor(X,Y) :- X >= 3, Y is 0.

good(X,Y) :- X < 3, X >= 0, Y is X/3.
good(X,Y) :- X >= 3, X =< 7, Y is 1.
good(X,Y) :- X > 7, X =< 10, Y is (10-X)/3.
good(X,Y) :- X > 10, Y is 0.

excellent(X,Y) :- X < 7, Y is 0.
excellent(X,Y) :- X >= 7, X =< 10, Y is (X-7)/3.
excellent(X,Y) :- X > 10, Y is 1.

% Food

rancid(X,Y) :- X =< 5, Y is 1.
rancid(X,Y) :- X > 5, X < 8, Y is (8-X)/3.
rancid(X,Y) :- X >= 8, Y is 0.

delicious(X,Y) :- X < 5, Y is 0.
delicious(X,Y) :- X >= 5, X < 8, Y is (X-5)/3.
delicious(X,Y) :- X >= 8, Y is 1.

% Tip

cheap(T,Y) :- T =< 0, Y is 1.
cheap(T,Y) :- T > 0, T < 10, Y is (10-T)/10.
cheap(T,Y) :- T >= 10, Y is 0.

normal(T,Y) :- T < 10, Y is 0.
normal(T,Y) :- T >= 10, T =< 15, Y is (T-10)/5.
normal(T,Y) :- T > 15, T =< 20, Y is (20-T)/5.
normal(T,Y) :- T > 20, Y is 0.

generous(T,Y) :- T < 15, Y is 0.
generous(T,Y) :- T >= 15, T =< 25, Y is (T-15)/10.
generous(T,Y) :- T > 25, Y is 1.


run :-
    repeat,
    ask_questions(Service, Food),
    read_Rules('lab6.txt', Rules),
    infer_tip(Rules, Service, Food, Tip),
    format('Recommended tip: ~2f~n', [Tip]),
    writeln('Type stop. to exit or anything else to continue.'),
    read(Command),
    Command == stop,
    !.


% infer_tip(+Rules, +Service, +Food, -Tip)

infer_tip(Rules, Service, Food, Tip) :-
    findall(Curve,
        (
            member([Connector, Antecedents, [TipPred]], Rules),
            eval_antecedent(Connector, Antecedents, Service, Food, RuleDegree),
            eval_consequent(TipPred, RuleDegree, Curve)
        ),
        Curves
    ),
    aggregate_consequents(Curves, Aggregated),
    defuzzify(Aggregated, Tip).


% read clauses from a file
read_Rules(File, Rules) :- 
    see(File), 
    read(Rules), 
    seen.


ask_questions(Service, Food) :-
    write('How good was the service? (number between 0 and 10)'), nl,
    read_line_to_string(user_input, ServiceStr),
    number_string(Service, ServiceStr),

    write('How good was the food? (number between 0 and 10)'), nl,
    read_line_to_string(user_input, FoodStr),
    number_string(Food, FoodStr).


% eval_antecedent(+Connector, +Preds, +Service, +Food, -Degree)
% Connector is 'and' or 'or'
% Preds is a list like [service/poor, food/rancid]

eval_antecedent(Connector, Preds, Service, Food, Degree) :-
    findall(Deg,
        (
            member(Type/Pred, Preds),
            ( 
                Type == service ->
                    call(Pred, Service, Deg)
                ; Type == food ->
                    call(Pred, Food, Deg)
            )
        ),
        Degrees
    ),
    ( 
        Connector == and ->
            min_list(Degrees, Degree)
        ; Connector == or ->
            max_list(Degrees, Degree)
    ).


% eval_consequent(+TipPred, +RuleDegree, -Curve)
% Curve = list of T-Degree pairs for T = 0..25

eval_consequent(tip/Pred, RuleDegree, Curve) :-
    findall(T-D,
        (
            between(0, 25, T),
            call(Pred, T, Degree),
            D is min(Degree, RuleDegree)
        ),
        Curve
    ).


% aggregate_consequents(+Curves, -AggregatedCurve)
% Curves is a list of curves (list of T-Degree pairs)

aggregate_consequents([C1, C2 | Rest], FinalCurve) :-
    aggregate_two_curves(C1, C2, AggCurve),
    aggregate_consequents([AggCurve | Rest], FinalCurve).

aggregate_consequents([Curve], Curve).


% aggregate_two_curves(+C1, +C2, -AggCurve)

aggregate_two_curves([], [], []).

aggregate_two_curves([], [], []).

aggregate_two_curves([T-D1 | Rest1], [T-D2 | Rest2], [T-D | RestAgg]) :-
    D is max(D1, D2),
    aggregate_two_curves(Rest1, Rest2, RestAgg).


% defuzzify(+AggregatedCurve, -Tip)
% formula: Tip = sum(D*T) / sum(D), where D is degree at T

defuzzify(Curve, Tip) :-
    findall(D * T, member(T-D, Curve), Products),
    findall(D, member(_-D, Curve), Degrees),
    sum_list(Products, SumTD),
    sum_list(Degrees, SumD),
    Tip is SumTD / SumD.