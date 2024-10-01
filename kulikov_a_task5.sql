--Решение. Задание 5. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: API для сущностей "Платеж" и "Детали платежа"
*/

--Создание платежа
declare
  v_message varchar2(100 char) := 'Платеж создан';
  c_create constant number(10,0) := 0;
  v_current_dtime date := sysdate;
  v_payment_id number(38,0);
begin
  dbms_output.put_line(v_message || '. Статус: ' || c_create);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss'));
end;
/

--Сброс платежа
declare
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  c_error constant number(10,0) := 2;
  v_reason varchar2(200 char) := 'недостаточно средств';
  v_current_dtime timestamp := systimestamp;
  v_payment_id number(38,0);
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if v_reason is null then
	  dbms_output.put_line('Причина не может быть пустой');
	end if;
  
  dbms_output.put_line(v_message || '. Статус: ' || c_error || '. Причина: ' || v_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss:ff'));
end;
/

--Отмена платежа
declare
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  c_cancel constant number(10,0) := 3;
  v_reason varchar2(200 char) := 'ошибка пользователя';
  v_current_dtime date := sysdate;
  v_payment_id number(38,0) := 15;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if v_reason is null then
	  dbms_output.put_line('Причина не может быть пустой');
	end if;
  
  dbms_output.put_line(v_message || '. Статус: '|| c_cancel ||'. Причина: ' || v_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd-mm-yyyy'));
end;
/

--Успешный платеж
declare
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success constant number(10,0) := 1;
  v_current_dtime timestamp := systimestamp;
  v_payment_id number(38,0);
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  dbms_output.put_line(v_message || '. Статус: ' || c_success);
  dbms_output.put_line(to_char(v_current_dtime,'dd Month yyyy hh24:mi'));
end;
/

--Добавление/изменение данных по платежу
declare
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime date := sysdate;
  v_payment_id number(38,0) := 120;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'hh24:mi:ss'));
end;
/

--Удаление данных по деталям платежа
declare
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
  v_payment_id number(38,0);
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'"Date: " dd Month yyyy ". Time: " hh24:mi:ss:ff'));
end;
/
