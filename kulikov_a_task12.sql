--Решение. Задание 12. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: API для сущностей "Платеж" и "Детали платежа"
*/

--Создание платежа
create or replace function create_payment(p_from_client_id client.client_id%type
                                         ,p_to_client_id client.client_id%type
                                         ,p_summa payment.summa%type
                                         ,p_currency_id currency.currency_id%type
                                         ,p_payment_detail t_payment_detail_array)
  return payment.payment_id%type
is
  v_message varchar2(100 char) := 'Платеж создан';
  c_create constant payment.status%type := 0;
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;                                                                 
  
begin
  
  if p_payment_detail is not empty then
    
    for i in p_payment_detail.first .. p_payment_detail.last loop
      
      if p_payment_detail(i).field_id is null then
        dbms_output.put_line('ID поля не может быть пустым');
      end if;
      
      if p_payment_detail(i).field_value is null then
        dbms_output.put_line('Значение в поле не может быть пустым');
      end if;
      
      dbms_output.put_line('Field_id: ' || p_payment_detail(i).field_id || '. Value: ' || p_payment_detail(i).field_value);
    end loop;
  
  else    
    dbms_output.put_line('Коллекция не содержит данных');  
  end if;

  dbms_output.put_line(v_message || '. Статус: ' || c_create);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss'));
  
  insert into payment(payment_id
                     ,create_dtime
                     ,summa
                     ,currency_id
                     ,from_client_id
                     ,to_client_id
                     ,status)
  values(payment_seq.nextval
        ,v_current_dtime
        ,p_summa
        ,p_currency_id
        ,p_from_client_id
        ,p_to_client_id
        ,c_create)
  return payment_id into v_payment_id;
  
  dbms_output.put_line('Payment_id of new payment: ' || v_payment_id);
  
  insert into payment_detail(payment_id
                            ,field_id
                            ,field_value)
  select v_payment_id
        ,value(t).field_id
        ,value(t).field_value
    from table(p_payment_detail) t;
  
  return v_payment_id;
end;
/

--Сброс платежа
create or replace procedure fail_payment (p_payment_id payment.payment_id%type
                                         ,p_reason payment.status_change_reason%type)
is
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  c_error constant payment.status%type := 2;
  c_create constant payment.status%type := 0;
  v_current_dtime timestamp := systimestamp;
  
begin
  if p_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if p_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;
  
  dbms_output.put_line(v_message || '. Статус: ' || c_error || '. Причина: ' || p_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss:ff'));
  
  update payment p
     set p.status = c_error
        ,p.status_change_reason = p_reason
   where p.payment_id = p_payment_id
     and p.status = c_create;
   
end;
/

--Отмена платежа
create or replace procedure cancel_payment (p_payment_id payment.payment_id%type
                                           ,p_reason payment.status_change_reason%type)
is
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  c_cancel constant payment.status%type := 3;
  c_create constant payment.status%type := 0;
  v_current_dtime timestamp := systimestamp;
begin
  if p_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if p_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;
  
  dbms_output.put_line(v_message || '. Статус: '|| c_cancel ||'. Причина: ' || p_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd-mm-yyyy'));
  
  update payment p
     set p.status = c_cancel
        ,p.status_change_reason = p_reason
   where p.payment_id = p_payment_id
     and p.status = c_create;
     
end;
/

--Успешный платеж
create or replace procedure successful_finish_payment (p_payment_id payment.payment_id%type)
is
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success constant payment.status%type := 1;
  c_create constant payment.status%type := 0;
  v_current_dtime timestamp := systimestamp;
begin
  if p_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  dbms_output.put_line(v_message || '. Статус: ' || c_success);
  dbms_output.put_line(to_char(v_current_dtime,'dd Month yyyy hh24:mi'));
  
  update payment p
     set p.status = c_success
        ,p.status_change_reason = null
   where p.payment_id = p_payment_id
     and p.status = c_create;
     
end;
/

--Добавление/изменение данных по платежу
create or replace procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type
                                                            ,p_payment_detail t_payment_detail_array)
is
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime timestamp := systimestamp;
begin
  
  if p_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if; 
   
  if p_payment_detail is not empty then
    
    for i in p_payment_detail.first .. p_payment_detail.last loop
      
      if p_payment_detail(i).field_id is null then
        dbms_output.put_line('ID поля не может быть пустым');
      end if;
      
      if p_payment_detail(i).field_value is null then
        dbms_output.put_line('Значение в поле не может быть пустым');
      end if;
      
      dbms_output.put_line('Field_id: ' || p_payment_detail(i).field_id || '. Value: ' || p_payment_detail(i).field_value);
    end loop;
  
  else    
    dbms_output.put_line('Коллекция не содержит данных');  
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'hh24:mi:ss'));
  
  merge into payment_detail pd
  using (select p_payment_id payment_id
               ,value(t).field_id field_id
               ,value(t).field_value field_value
           from table(p_payment_detail) t) n
     on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
  when matched then
    update set pd.field_value = n.field_value
  when not matched then
    insert (payment_id
           ,field_id
           ,field_value
           )
    values (n.payment_id
           ,n.field_id
           ,n.field_value
           );
  
end;
/

--Удаление данных по деталям платежа
create or replace procedure delete_payment_detail (p_payment_id payment.payment_id%type
                                                  ,p_delete_field_ids t_number_array)
is
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
begin
  
  if p_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if p_delete_field_ids is null or p_delete_field_ids is empty then
    dbms_output.put_line('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'"Date: " dd Month yyyy ". Time: " hh24:mi:ss:ff'));
  dbms_output.put_line('Количество полей для удаления: ' || p_delete_field_ids.count());
  
  delete payment_detail pd
   where pd.payment_id = p_payment_id
     and pd.field_id in (select value(t) from table(p_delete_field_ids) t);
  
end;
/
