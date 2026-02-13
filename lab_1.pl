/* Задание 1. Задайте функцию distance(P1, P2), находящую расстояние между точками P1 и

P2, каждая из которых задана как кортеж из двух чисел. Используйте
библиотечную функцию math:sqrt().
distance({1.0, 2.0}, {0.0, 1.0}) => sqrt(2) (приближённо 1.4142...) */

distance(point(APosX, APosY), point(BPosX, BPosY), Distance) :-
  DeltaX is abs(APosX - BPosX),
  DeltaY is abs(APosY - BPosY),
  Distance is sqrt(DeltaX * DeltaX + DeltaY * DeltaY).

% ?- distance(point(1.0, 2.0), point(0.0, 1.0), Distance).

/* Задание 2. Задайте функцию insert(List, X), которая получает отсортированный в порядке
возрастания список List и число X, и добавляет X в List так, чтобы снова получить
список в порядке возрастания.
insert([1, 1.5, 2, 2.5, 3.5], 3) => [1, 1.5, 2, 2.5, 3, 3.5]. */

insert([], ValueToInsert, [ValueToInsert]).
insert([Head|Tail], ValueToInsert, [ValueToInsert, Head|Tail]) :-
  ValueToInsert =< Head, !.
insert([Head|Tail], ValueToInsert, [Head|Result]) :-
  ValueToInsert > Head,
  insert(Tail, ValueToInsert, Result).

% ?- insert([1, 1.5, 2, 2.5, 3.5], 3, Result).

/* Задание 3. Задайте функцию drop_every(List, N), удаляющую каждый N-ый элемент из
списка List.
drop_every([1,2,3,4,5,6,7], 2) => [1,3,5,7]
drop_every([1,2,3,4,5,6,7], 3) => [1,2,4,5,7] */

drop_every(List, ItemsCount, Result) :-
  drop_every(List, ItemsCount, 1, Result).
drop_every([], _, _, []).
drop_every([_|Tail], ItemsCount, ItemsCount, Result) :-
  !,
  drop_every(Tail, ItemsCount, 1, Result).
drop_every([Head|Tail], ItemsCount, C, [Head|Rest]) :-
  C < ItemsCount,
  !,
  NextC is C + 1,
  drop_every(Tail, ItemsCount, NextC, Rest).

% ?- drop_every([1, 2, 3, 4, 5, 6, 7], 2, Result).
% ?- drop_every([1, 2, 3, 4, 5, 6, 7], 3, Result).

/* Задание 4. Задайте функцию rle_decode(EncodedList), которая работает противоположно
функции rle_encode из варианта 1.
decode([{a,3},b,{c,2},{a,2}]) => [a,a,a,b,c,c,a,a] */

rle_decode([], []).
rle_decode([encoded_char(Char, Count)|Rest], DecodedList) :-
    Count > 0,
    repeat_element(Char, Count, RepeatedChars),
    rle_decode(Rest, DecodedRest),
    append(RepeatedChars, DecodedRest, DecodedList).
rle_decode([Element|Rest], [Element|DecodedRest]) :-
    \+ (Element = encoded_char(_, _)),
    rle_decode(Rest, DecodedRest).

repeat_element(_, 0, []).
repeat_element(Char, N, [Char|Rest]) :-
    N > 0,
    N1 is N - 1,
    repeat_element(Char, N1, Rest).

% ?- rle_decode([encoded_char(a, 3), b, encoded_char(c, 2), encoded_char(a, 2)], DecodedList).

/* Задание 5. Задайте функцию diagonal(Matrix), которая возвращает диагональ матрицы,
заданной как список списков.
diagonal([[1,2,3], [4,5,6], [7,8,9]]) => [1,5,9] */

diagonal(Matrix, Diagonal) :-
    diagonal_helper(Matrix, 0, Diagonal).

diagonal_helper([], _, []).
diagonal_helper([Row|RestMatrix], Position, [Element|RestDiagonal]) :-
    nth_element(Row, Position, Element),
    NextPosition is Position + 1,
    diagonal_helper(RestMatrix, NextPosition, RestDiagonal).

nth_element([Head|_], 0, Head).
nth_element([_|Tail], N, Element) :-
    N > 0,
    N1 is N - 1,
    nth_element(Tail, N1, Element).

% ?- diagonal([[1, 2, 3], [4, 5, 6], [7, 8, 9]], DiagonalList).

/* Задание 6. Задайте функцию intersect(List1, List2), находящую все общие элементы двух списков
List1 и List2.
intersect([1, 3, 2, 5], [2, 3, 4]) => [3, 2] (или [2, 3]).
intersect([1, 6, 5], [2, 3, 4]) => []. */

intersect(List1, List2, Intersection) :-
    intersect_helper(List1, List2, [], Intersection).

intersect_helper([], _, Acc, Acc).
intersect_helper([X|Tail], List2, Acc, Intersection) :-
    member(X, List2),
    not(member(X, Acc)),
    !,
    intersect_helper(Tail, List2, [X|Acc], Intersection).

intersect_helper([_|Tail], List2, Acc, Intersection) :-
    intersect_helper(Tail, List2, Acc, Intersection).

% ?- intersect([1, 3, 2, 5], [2, 3, 4], Result).
% ?- intersect([1, 6, 5], [2, 3, 4], Result).

/* Задание 7. Задайте функцию is_date(DayOfMonth, MonthOfYear, Year), определяющуе номер дня
недели по числу месяца, номеру месяца и году.
Напомню, что год является високосным, если он либо делится на 4, но не на 100, либо
делится на 400.
В качестве точки отсчёта возьмите 1 января 2000 года (суббота). Не используйте каких-то
формул для нахождения дня недели, это задание на рекурсию!
is_date(1, 1, 2000) => 6
is_date(1, 2, 2013) => 5 */

is_date(Day, Month, Year, WeekDay) :-
    days_from_reference(Day, Month, Year, TotalDays),
    WeekDay is ((TotalDays + 5) mod 7) + 1.

days_from_reference(Day, Month, Year, TotalDays) :-
    days_in_years(2000, Year, DaysFromYears),
    days_in_months(Year, 1, Month, DaysFromMonths),
    TotalDays is DaysFromYears + DaysFromMonths + Day - 1.

days_in_years(EndYear, EndYear, 0).
days_in_years(StartYear, EndYear, Days) :-
    StartYear < EndYear,
    days_in_year(StartYear, DaysInYear),
    NextYear is StartYear + 1,
    days_in_years(NextYear, EndYear, RemainingDays),
    Days is DaysInYear + RemainingDays.

days_in_year(Year, 366) :- leap_year(Year), !.
days_in_year(_, 365).

leap_year(Year) :-
    (0 is Year mod 400 -> true;
     (0 is Year mod 4, 0 is Year mod 100 -> false;
     0 is Year mod 4)).

days_in_months(_, EndMonth, EndMonth, 0).
days_in_months(Year, StartMonth, EndMonth, Days) :-
    StartMonth < EndMonth,
    days_in_month(Year, StartMonth, DaysInMonth),
    NextMonth is StartMonth + 1,
    days_in_months(Year, NextMonth, EndMonth, RemainingDays),
    Days is DaysInMonth + RemainingDays.

days_in_month(_, 1, 31).   % Январь
days_in_month(Year, 2, 29) :- leap_year(Year), !.  % Февраль високосного года
days_in_month(_, 2, 28).   % Февраль невисокосного года
days_in_month(_, 3, 31).   % Март
days_in_month(_, 4, 30).   % Апрель
days_in_month(_, 5, 31).   % Май
days_in_month(_, 6, 30).   % Июнь
days_in_month(_, 7, 31).   % Июль
days_in_month(_, 8, 31).   % Август
days_in_month(_, 9, 30).   % Сентябрь
days_in_month(_, 10, 31).  % Октябрь
days_in_month(_, 11, 30).  % Ноябрь
days_in_month(_, 12, 31).  % Декабрь

% ?- is_date(1, 1, 2000, WeekDay).
% ?- is_date(1, 2, 2013, WeekDay).
% ?- is_date(14, 3, 2026, WeekDay).
%
% Дни недели кодируются числами:
% 1 - Понедельник
% 2 - Вторник
% 3 - Среда
% 4 - Четверг
% 5 - Пятница
% 6 - Суббота
% 7 - Воскресенье
