--Решение. Задание 6. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: API для сущностей "Платеж" и "Детали платежа"
*/

--Создание платежа
declare
  v_message varchar2(100 char) := 'Платеж создан';
  c_create constant payment.status%type := 0;
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type;
begin
  dbms_output.put_line(v_message || '. Статус: ' || c_create);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss'));
end;
/

--Сброс платежа
declare
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  c_error constant payment.status%type := 2;
  v_reason payment.status_change_reason%type := 'недостаточно средств';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;
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
  c_cancel constant payment.status%type := 3;
  v_reason payment.status_change_reason%type := 'ошибка пользователя';
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type := 15;
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
  c_success constant payment.status%type := 1;
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;
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
  v_payment_id payment.payment_id%type := 120;
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
  v_payment_id payment.payment_id%type;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'"Date: " dd Month yyyy ". Time: " hh24:mi:ss:ff'));
end;
/
