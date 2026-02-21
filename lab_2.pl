/* Задание 1. Реализуйте функцию list_lengths(List), которая возвращает список длин списков,
входящих в List и пропускает все остальные элементы.
list_lengths([[1,2,3], {true,3}, [4,5], []]) => [3,2,0] */

list_lengths([], []).

list_lengths([H|T], [Len|Result]) :-
    is_list(H),
    length(H, Len),
    list_lengths(T, Result).

list_lengths([_|T], Result) :-
    not(is_list(_)),
    list_lengths(T, Result).

% ?- list_lengths([[1,2,3], {true,3}, [4,5], []], Result).

/* Задание 2. Не смотря на определение в модуле lists стандартной библиотеки, реализуйте
функцию all(Pred, List).
Она возвращает true, если Pred возвращает true для всех элементов List, и false,
если это не так.
all(fun(X) -> X < 10 end, [1,3,9,11,6]) => false
all(fun(X) -> X < 10 end, [1,3,9,6]) => true */

all(_, []).

all(Pred, [H|T]) :-
    call(Pred, H),
    all(Pred, T).

less_than_10(X) :- X < 10.

% ?- all(less_than_10, [1,3,9,11,6]).
% ?- all(less_than_10, [1,3,9,6]).

/* Задание 3. Реализуйте функцию min_value(F, N), которая возвращает минимальное
значение функции F на целых числах от 1 до N.
max_value(fun(X) -> X rem 5 end, 10) => 0 */

min_value(F, N) :-
    min_value(F, N, 1, 0, Min),
    write('Минимальное значение: '), write(Min), nl.

min_value(F, N, Current, Min, Result) :-
    Current =< N,
    call(F, Current, Value),
    (Current == 1 -> 
        NewMin = Value
    ; 
        (Value < Min -> NewMin = Value ; NewMin = Min)
    ),
    Next is Current + 1,
    min_value(F, N, Next, NewMin, Result).

min_value(_, N, Current, Min, Min) :-
    Current > N.

mod5(X, Result) :- Result is X mod 5.

% ?- min_value(mod5, 10).

/* Задание 4. Реализуйте функцию group_by(Fun, List), которая разбивает список List на
отрезки, на идущих подряд элементах которых Fun (предикат от двух переменных)
возвращает true.
group_by(fun(X, Y) <- X =< Y end, [1,2,4,3,2,5]) => [[1,2,4], [3], [2,5]] */

group_by(_, [], []).

group_by(Pred, [H|T], [Group|RestGroups]) :-
    group_by_helper(Pred, [H|T], Group, Remaining),
    group_by(Pred, Remaining, RestGroups).

group_by_helper(_, [], [], []).

group_by_helper(_, [X], [X], []).

group_by_helper(Pred, [X,Y|T], [X|GroupRest], Remaining) :-
    call(Pred, X, Y),
    group_by_helper(Pred, [Y|T], GroupRest, Remaining).

group_by_helper(Pred, [X,Y|T], [X], [Y|T]) :-
    not(call(Pred, X, Y)).

less_or_equal(X, Y) :- X =< Y.

% ?- group_by(less_or_equal, [1,2,4,3,2,5], Result).

/* Задание 5. Реализуйте функцию for(Init, Cond, Step, Body), которая работает как цикл for (I = Init;
Cond(I); I = Step(I)) { Body(I) } в C-подобных языках:
# поддерживается "текущее значение" I. В начале это Init.
# на каждом шаге проверяется, выполняется ли условие Cond(I).
# если да, то вызывается функция Body(I). Потом вычисляется новое значение как Step(I)
и возвращаемся к проверке Cond.
# если нет, то работа функции заканчивается. */

for(Init, Cond, Step, Body) :-
    call(Cond, Init),
    !,
    call(Body, Init),
    call(Step, Init, Next),
    for(Next, Cond, Step, Body).

for(_, _, _, _).

cond_less_or_equal_5(X) :-
    X =< 5.

step_inc(X, Y) :-
    Y is X + 1.

body_print(X) :-
    write('Итерация: '), write(X), nl.

% Пример использования:
% ?- for(1, cond_less_or_equal_5, step_inc, body_print).

/* Задание 6. Реализуйте функцию sortBy(Comparator, List), которая сортирует список List, используя
Comparator для сравнения элементов. Comparator(X, Y) возвращает один из атомов less
(если X < Y), equal (X == Y), greater (X > Y) для любых элементов List. Можете
использовать любой алгоритм сортировки, но укажите, какой именно. Сортировка
слиянием очень хорошо подходит для связных списков. */

sortBy(Comparator, List, Sorted) :-
    length(List, Len),
    sortBy_helper(Comparator, List, Len, Sorted).

sortBy_helper(_, [], 0, []) :- !.
sortBy_helper(_, [X], 1, [X]) :- !.
sortBy_helper(Comparator, List, Len, Sorted) :-
    HalfLen is Len // 2,
    split_list(List, HalfLen, Left, Right),
    
    length(Left, LeftLen),
    length(Right, RightLen),
    sortBy_helper(Comparator, Left, LeftLen, SortedLeft),
    sortBy_helper(Comparator, Right, RightLen, SortedRight),
    
    merge_lists(Comparator, SortedLeft, SortedRight, Sorted).

split_list(List, N, Left, Right) :-
    split_list_helper(List, N, Left, Right).

split_list_helper(Rest, 0, [], Rest) :- !.
split_list_helper([X|Xs], N, [X|Left], Right) :-
    N > 0,
    N1 is N - 1,
    split_list_helper(Xs, N1, Left, Right).

merge_lists(_, [], Right, Right) :- !.
merge_lists(_, Left, [], Left) :- !.
merge_lists(Comparator, [X|LeftTail], [Y|RightTail], [X|Merged]) :-
    call(Comparator, X, Y, Result),
    Result = less,  % X меньше Y
    !,
    merge_lists(Comparator, LeftTail, [Y|RightTail], Merged).

merge_lists(Comparator, [X|LeftTail], [Y|RightTail], [Y|Merged]) :-
    call(Comparator, X, Y, Result),
    (Result = greater ; Result = equal),  % X >= Y
    !,
    merge_lists(Comparator, [X|LeftTail], RightTail, Merged).

% Компаратор для чисел (по возрастанию)
compare_numbers(X, Y, less) :- X < Y, !.
compare_numbers(X, Y, equal) :- X =:= Y, !.
compare_numbers(_, _, greater).

% Компаратор для чисел (по убыванию)
compare_numbers_desc(X, Y, greater) :- X < Y, !.
compare_numbers_desc(X, Y, equal) :- X =:= Y, !.
compare_numbers_desc(_, _, less).

% Компаратор для строк (по алфавиту)
compare_strings(X, Y, less) :- X @< Y, !.
compare_strings(X, Y, equal) :- X == Y, !.
compare_strings(_, _, greater).

% Компаратор для списков по длине
compare_by_length(X, Y, less) :- length(X, LX), length(Y, LY), LX < LY, !.
compare_by_length(X, Y, equal) :- length(X, LX), length(Y, LY), LX =:= LY, !.
compare_by_length(_, _, greater).

% Компаратор для пар по первому элементу
compare_pairs_first((A,_), (B,_), less) :- A < B, !.
compare_pairs_first((A,_), (B,_), equal) :- A =:= B, !.
compare_pairs_first(_, _, greater).

% 1. Сортировка чисел по возрастанию
% ?- sortBy(compare_numbers, [5, 2, 8, 1, 9, 3], Sorted).

% 2. Сортировка чисел по убыванию
% ?- sortBy(compare_numbers_desc, [5, 2, 8, 1, 9, 3], Sorted).

% 3. Сортировка строк
% ?- sortBy(compare_strings, ["banana", "apple", "cherry", "date"], Sorted).

% 4. Сортировка списков по длине
% ?- sortBy(compare_by_length, [[1,2], [1,2,3,4], [1], [1,2,3]], Sorted).

% 5. Сортировка пар по первому элементу
% ?- sortBy(compare_pairs_first, [(3,three), (1,one), (4,four), (2,two)], Sorted).

% 6. Проверка устойчивости сортировки (с equal)
% ?- sortBy(compare_numbers, [3, 1, 4, 1, 5, 9, 2, 6], Sorted).
