--Решение. Задание 11. Куликов А.А.

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
  v_summa payment.summa%type := 10000;
  v_currency_id currency.currency_id%type := 643; 
  v_from_client_id client.client_id%type := 1;
  v_to_client_id client.client_id%type := 2;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                   ,t_payment_detail(2,'199.5.49.657')
                                                                   ,t_payment_detail(3,'пополнение через терминал') 
                                                                   );                                                                 
  
begin
  
  if v_payment_detail is not empty then
    
    for i in v_payment_detail.first .. v_payment_detail.last loop
      
      if v_payment_detail(i).field_id is null then
        dbms_output.put_line('ID поля не может быть пустым');
      end if;
      
      if v_payment_detail(i).field_value is null then
        dbms_output.put_line('Значение в поле не может быть пустым');
      end if;
      
      dbms_output.put_line('Field_id: ' || v_payment_detail(i).field_id || '. Value: ' || v_payment_detail(i).field_value);
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
        ,v_summa
        ,v_currency_id
        ,v_from_client_id
        ,v_to_client_id
        ,c_create)
  return payment_id into v_payment_id;
  
  dbms_output.put_line('Payment_id of new payment: ' || v_payment_id);
  
  insert into payment_detail(payment_id
                            ,field_id
                            ,field_value)
  select v_payment_id
        ,value(t).field_id
        ,value(t).field_value
    from table(v_payment_detail) t;
  
end;
/

--Сброс платежа
declare
  v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
  c_error constant payment.status%type := 2;
  c_create constant payment.status%type := 0;
  v_reason payment.status_change_reason%type := 'недостаточно средств';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type := 2;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if v_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;
  
  dbms_output.put_line(v_message || '. Статус: ' || c_error || '. Причина: ' || v_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss:ff'));
  
  update payment p
     set p.status = c_error
        ,p.status_change_reason = v_reason
   where p.payment_id = v_payment_id
     and p.status = c_create;
   
end;
/

--Отмена платежа
declare
  v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
  c_cancel constant payment.status%type := 3;
  c_create constant payment.status%type := 0;
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
  
  update payment p
     set p.status = c_cancel
        ,p.status_change_reason = v_reason
   where p.payment_id = v_payment_id
     and p.status = c_create;
     
end;
/

--Успешный платеж
declare
  v_message varchar2(200 char) := 'Успешное завершение платежа';
  c_success constant payment.status%type := 1;
  c_create constant payment.status%type := 0;
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  dbms_output.put_line(v_message || '. Статус: ' || c_success);
  dbms_output.put_line(to_char(v_current_dtime,'dd Month yyyy hh24:mi'));
  
  update payment p
     set p.status = c_success
   where p.payment_id = v_payment_id
     and p.status = c_create;
     
end;
/

--Добавление/изменение данных по платежу
declare
  v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type := 3;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if; 
   
  if v_payment_detail is not empty then
    
    for i in v_payment_detail.first .. v_payment_detail.last loop
      
      if v_payment_detail(i).field_id is null then
        dbms_output.put_line('ID поля не может быть пустым');
      end if;
      
      if v_payment_detail(i).field_value is null then
        dbms_output.put_line('Значение в поле не может быть пустым');
      end if;
      
      dbms_output.put_line('Field_id: ' || v_payment_detail(i).field_id || '. Value: ' || v_payment_detail(i).field_value);
    end loop;
  
  else    
    dbms_output.put_line('Коллекция не содержит данных');  
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'hh24:mi:ss'));
  
  merge into payment_detail pd
  using (select v_payment_id payment_id
               ,value(t).field_id field_id
               ,value(t).field_value field_value
           from table(v_payment_detail) t) n
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
declare
  v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type := 2;
  v_delete_field_ids t_number_array := t_number_array(1, 2);
begin
  
  if v_payment_id is null then 
    dbms_output.put_line('ID платежа не может быть пустым');
  end if;
  
  if v_delete_field_ids is empty then
    dbms_output.put_line('Коллекция не содержит данных');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'"Date: " dd Month yyyy ". Time: " hh24:mi:ss:ff'));
  dbms_output.put_line('Количество полей для удаления: ' || v_delete_field_ids.count());
  
  delete payment_detail pd
   where pd.payment_id = v_payment_id
     and pd.field_id in (select value(t) from table(v_delete_field_ids) t);
  
end;
/
