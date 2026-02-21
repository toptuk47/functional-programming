/* Задание 1. Реализуйте функцию flatten(bin_tree) -> list. flatten(Tree) возвращает список всех
данных в дереве в порядке возрастания. */

% Определение структуры бинарного дерева
% tree(Значение, ЛевоеПоддерево, ПравоеПоддерево)
% empty - пустое дерево

% Базовый случай: пустое дерево дает пустой список
flatten(empty, []).

% Для непустого дерева: рекурсивно обходим левое поддерево, добавляем корень,
% затем обходим правое поддерево
flatten(tree(Value, Left, Right), Result) :-
    flatten(Left, LeftList),
    flatten(Right, RightList),
    append(LeftList, [Value|RightList], Result).

% ?- flatten(tree(5, tree(3, tree(1, empty, empty), tree(4, empty, empty)), tree(7, tree(6, empty, empty), tree(8, empty, empty))), Result).

/* Задание 2. Разработайте интерфейс для абстрактного типа данных "словарь". Словарь позволяет хранить 
произвольное число пар ключ-значение без определённого порядка, при этом две пары с одним ключом
одновременно не допускаются. */

% Источник: https://ru.wikipedia.org/wiki/Ассоциативный_массив

% Интерфейс словаря (для каждой реализации необходимо определить следующие предикаты):

% dict_new(Dict) - создает новый пустой словарь
% dict_insert(Key, Value, DictIn, DictOut) - добавляет пару ключ-значение
% dict_find(Key, Dict, Value) - ищет значение по ключу
% dict_remove(Key, DictIn, DictOut) - удаляет пару по ключу
% dict_is_empty(Dict) - проверяет, пуст ли словарь
% dict_size(Dict, Size) - возвращает количество элементов в словаре

/* Задание 3. Реализуйте над этим интерфейсом функцию all_values(dictionary) -> [any].
all_values(Dict) возвращает список всех значений в словаре. */

% O(n)
all_values(Dict, Values) :-
    (   is_list(Dict) ->
        Pairs = Dict
    ;   dict_to_list_tree(Dict, Pairs)
    ),
    pairs_values(Pairs, Values). % Извлекаем только значения

pairs_values([], []).
pairs_values([(_, Value)|Pairs], [Value|Values]) :-
    pairs_values(Pairs, Values).

% Тут должны быть запросы для проверки

/* Задание 4. Разработайте 1 (для частичного зачёта) или 2 реализации этого интерфейса. */

/* --- Реализация на основе списка пар --- */

% Создание нового пустого словаря O(1)
dict_new_list([]).

% Вставка пары ключ-значение (заменяет существующую пару с таким же ключом) O(n)
dict_insert_list(Key, Value, DictIn, DictOut) :-
    % Сначала удаляем все существующие пары с таким ключом
    remove_all_by_key(Key, DictIn, DictWithoutKey),
    % Добавляем новую пару в начало списка
    DictOut = [(Key, Value) | DictWithoutKey].

% Вспомогательный предикат для удаления всех пар с заданным ключом O(n)
remove_all_by_key(_, [], []).
remove_all_by_key(Key, [(Key, _)|T], Result) :-
    !,  % Пропускаем эту пару
    remove_all_by_key(Key, T, Result).
remove_all_by_key(Key, [Pair|T], [Pair|Result]) :-
    Pair = (K, _),
    K \= Key,
    remove_all_by_key(Key, T, Result).

% Поиск значения по ключу O(n)
dict_find_list(Key, Dict, Value) :-
    member((Key, Value), Dict).

% Удаление пары по ключу (удаляем все пары с заданным ключом) O(n)
dict_remove_list(Key, DictIn, DictOut) :-
    remove_all_by_key(Key, DictIn, DictOut).

% Проверка на пустоту O(n)
dict_is_empty_list([]).

% Размер словаря O(n)
dict_size_list(Dict, Size) :-
    length(Dict, Size).

% Преобразование словаря в список пар O(1)
dict_to_list(Dict, Dict).  % Словарь уже является списком пар

% ?- dict_new_list(D0),
%    dict_insert_list(a, 1, D0, D1),
%    dict_insert_list(b, 2, D1, D2),
%    dict_insert_list(a, 3, D2, D3),
%    dict_find_list(a, D3, Value),
%    write(Value), nl,
%    dict_remove_list(b, D3, D4),
%    all_values(D4, Values),
%    write(Values).

/* --- Реализация на основе бинарного дерева поиска (для отсортированных ключей) --- */

% Создание нового пустого словаря O(1)
dict_new_tree(empty).

% Вставка пары ключ-значение в дерево (заменяет существующую пару с таким же ключом) O(log n)
dict_insert_tree(Key, Value, empty, tree(Key, Value, empty, empty)) :- !.

dict_insert_tree(Key, Value, tree(K, _, Left, Right), tree(K, NewV, Left, Right)) :-
    Key == K,
    !,
    NewV = Value.  % Заменяем значение при совпадении ключа

dict_insert_tree(Key, Value, tree(K, V, Left, Right), tree(K, V, NewLeft, Right)) :-
    Key @< K,
    !,
    dict_insert_tree(Key, Value, Left, NewLeft).

dict_insert_tree(Key, Value, tree(K, V, Left, Right), tree(K, V, Left, NewRight)) :-
    Key @> K,
    dict_insert_tree(Key, Value, Right, NewRight).

% Поиск значения по ключу O(log n)
dict_find_tree(Key, tree(Key, Value, _, _), Value) :- !.

dict_find_tree(Key, tree(K, _, Left, _), Value) :-
    Key @< K,
    !,
    dict_find_tree(Key, Left, Value).

dict_find_tree(Key, tree(K, _, _, Right), Value) :-
    Key @> K,
    dict_find_tree(Key, Right, Value).

% Удаление пары по ключу O(log n)
dict_remove_tree(_, empty, empty) :- !.

dict_remove_tree(Key, tree(Key, _, Left, Right), Result) :-
    !,
    remove_root(Left, Right, Result).

dict_remove_tree(Key, tree(K, V, Left, Right), tree(K, V, NewLeft, Right)) :-
    Key @< K,
    !,
    dict_remove_tree(Key, Left, NewLeft).

dict_remove_tree(Key, tree(K, V, Left, Right), tree(K, V, Left, NewRight)) :-
    Key @> K,
    dict_remove_tree(Key, Right, NewRight).

% Вспомогательный предикат для удаления корня дерева
remove_root(empty, Right, Right) :- !.
remove_root(Left, empty, Left) :- !.
remove_root(Left, Right, tree(MinKey, MinValue, Left, NewRight)) :-
    get_min(Right, MinKey, MinValue, NewRight).

% Получение минимального элемента из дерева и удаление его O(h)
get_min(tree(Key, Value, empty, Right), Key, Value, Right) :- !.
get_min(tree(K, V, Left, Right), MinKey, MinValue, tree(K, V, NewLeft, Right)) :-
    get_min(Left, MinKey, MinValue, NewLeft).

% Проверка на пустоту O(1)
dict_is_empty_tree(empty).

% Размер словаря O(n)
dict_size_tree(empty, 0).
dict_size_tree(tree(_, _, Left, Right), Size) :-
    dict_size_tree(Left, LeftSize),
    dict_size_tree(Right, RightSize),
    Size is LeftSize + RightSize + 1.

% Преобразование словаря в список пар (симметричный обход) O(n)
dict_to_list_tree(empty, []).
dict_to_list_tree(tree(Key, Value, Left, Right), List) :-
    dict_to_list_tree(Left, LeftList),
    dict_to_list_tree(Right, RightList),
    append(LeftList, [(Key, Value)|RightList], List).

% ?- dict_new_tree(D0),
%    dict_insert_tree(c, 3, D0, D1),
%    dict_insert_tree(a, 1, D1, D2),
%    dict_insert_tree(b, 2, D2, D3),
%    dict_find_tree(b, D3, Value),
%    write(Value), nl,
%    dict_remove_tree(a, D3, D4),
%    dict_to_list_tree(D4, List),
%    write(List), nl,
%    all_values(D4, Values),
%    write(Values).
