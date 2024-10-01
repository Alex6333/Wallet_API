--Решение. Задание 3. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: API для сущностей "Платеж" и "Детали платежа"
*/

--Создание платежа
declare
  v_message varchar2(100) := 'Платеж создан';
  c_create constant number := 0;
begin
  dbms_output.put_line(v_message || '. Статус: ' || c_create);
end;
/

--Сброс платежа
declare
  v_message varchar2(200) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  c_error constant number := 2;
  v_reason varchar2(200) := 'недостаточно средств';
begin
  dbms_output.put_line(v_message || '. Статус: ' || c_error || '. Причина: ' || v_reason);
end;
/

--Отмена платежа
declare
  v_message varchar2(200) := 'Отмена платежа с указанием причины';
  c_cancel constant number := 3;
  v_reason varchar2(200) := 'ошибка пользователя';
begin
  dbms_output.put_line(v_message || '. Статус: '|| c_cancel ||'. Причина: ' || v_reason);
end;
/

--Успешный платеж
declare
  v_message varchar2(200) := 'Успешное завершение платежа';
  c_success constant number := 1;
begin
  dbms_output.put_line(v_message || '. Статус: ' || c_success);
end;
/

--Добавление/изменение данных по платежу
declare
  v_message varchar2(200) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
begin
  dbms_output.put_line(v_message);
end;
/

--Удаление данных по деталям платежа
declare
  v_message varchar2(200) := 'Детали платежа удалены по списку id_полей';
begin
  dbms_output.put_line(v_message);
end;
/
