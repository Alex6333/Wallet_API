--Решение. Задание 2. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: API для сущностей "Платеж" и "Детали платежа"
*/

--Создание платежа
begin
  dbms_output.put_line('Платеж создан. Статус: 0');
end;
/

--Сброс платежа
begin
  dbms_output.put_line('Сброс платежа в "ошибочный статус" с указанием причины. Статус: 2. Причина: недостаточно средств');
end;
/

--Отмена платежа
begin
  dbms_output.put_line('Отмена платежа с указанием причины. Статус: 3. Причина: ошибка пользователя');
end;
/

--Успешный платеж
begin
  dbms_output.put_line('Успешное завершение платежа. Статус: 1');
end;
/

--Добавление/изменение данных по платежу
begin
  dbms_output.put_line('Данные платежа добавлены или обновлены по списку id_поля/значение');
end;
/

--Удаление данных по деталям платежа
begin
  dbms_output.put_line('Детали платежа удалены по списку id_полей');
end;
/