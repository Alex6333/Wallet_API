--Решение. Задание 15. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: Unit-тесты для API для сущностей "Платеж" и "Детали платежа"
*/
select status
      ,t.*
  from user_objects t
 where t.object_type in ('TRIGGER', 'PACKAGE', 'PACKAGE BODY')
 order by t.object_type, t.OBJECT_NAME;
/

---- Позитивные тесты

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
  v_create_dtime_tech client.create_dtime_tech%type;
  v_update_dtime_tech client.update_dtime_tech%type;
begin
  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  dbms_output.put_line('ID созданного платежа: ' || v_payment_id);
  
  select p.create_dtime_tech
        ,p.update_dtime_tech
  into   v_create_dtime_tech
        ,v_update_dtime_tech
  from payment p
  where p.payment_id = v_payment_id;
  
  --проверка работы триггера
  if v_create_dtime_tech != v_update_dtime_tech then
    raise_application_error(-20998,'Технические даты разные!');    
  end if;
  
  commit;
end;
/

select * 
  from payment p 
 where p.payment_id = 121;
 
select pd.*
      ,f.description 
  from payment_detail pd 
  join payment_detail_field f on f.field_id = pd.field_id 
 where pd.payment_id = 121;
/

--Проверка сброса платежа
declare
  v_payment_id    payment.payment_id%type              := 121;
  v_reason        payment.status_change_reason%type    := 'Тестовый сброс платежа';
  v_create_dtime_tech client.create_dtime_tech%type;
  v_update_dtime_tech client.update_dtime_tech%type;
begin
  payment_api_pack.fail_payment(p_payment_id => v_payment_id
                               ,p_reason     => v_reason);
                               
  select p.create_dtime_tech
        ,p.update_dtime_tech
  into   v_create_dtime_tech
        ,v_update_dtime_tech
  from payment p
  where p.payment_id = v_payment_id;
  
  --проверка работы триггера
  if v_create_dtime_tech = v_update_dtime_tech then
    raise_application_error(-20998,'Технические даты одинаковые!');    
  end if;
  
end;
/

select * from payment p where p.payment_id = 121;
/

--Проверка отмены платежа
declare  
  v_payment_id    payment.payment_id%type              := 121;
  v_reason        payment.status_change_reason%type    := 'Тестовая отмена платежа';
begin
  payment_api_pack.cancel_payment(p_payment_id => v_payment_id
                                 ,p_reason     => v_reason);
end;
/

select * from payment p where p.payment_id = 121;
/

--Проверка успешного завершения платежа
declare
  v_payment_id payment.payment_id%type := 121;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
end;
/

select * from payment p where p.payment_id = 121;
/

--Проверка добавления/изменения данных по платежу
declare
  v_payment_id payment.payment_id%type    := 121;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id
                                                         ,p_payment_detail => v_payment_detail);
end;
/

select pd.*
      ,f.description 
  from payment_detail pd 
  join payment_detail_field f on f.field_id = pd.field_id 
 where pd.payment_id = 121;
/

--Проверка удаления деталей платежа
declare
  v_payment_id payment.payment_id%type := 101;
  v_delete_field_ids t_number_array    := t_number_array(1, 2);
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id       => v_payment_id
                                               ,p_delete_field_ids => v_delete_field_ids);
end;
/

select pd.*
      ,f.description 
  from payment_detail pd 
  join payment_detail_field f on f.field_id = pd.field_id 
 where pd.payment_id = 121;
/

-- Проверка функционала по глобальному разрешению. Операция удаления платежа
declare
  v_payment_id payment.payment_id%type := -1;
begin
  common_pack.enable_manual_changes();
      
  delete from payment p where p.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
  
exception
  when others then
    common_pack.disable_manual_changes();
    raise;    
end;
/

-- Проверка функционала по глобальному разрешению. Операция изменения платежа
declare
  v_payment_id payment.payment_id%type := -1;
  v_summa      payment.summa%type      := 999999999;
begin
  common_pack.enable_manual_changes();
  
  update payment p
     set p.summa = v_summa
   where p.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
  
exception
  when others then
    common_pack.disable_manual_changes();
    raise;    
end;
/

-- Проверка функционала по глобальному разрешению. Операция изменения данных платежа
declare
  v_payment_id payment.payment_id%type := -1;
begin
  common_pack.enable_manual_changes();
  
  update payment_detail pd
     set pd.field_value = pd.field_value
   where pd.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
  
exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/

---- Негативные тесты

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin
  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => null);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');
  
exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin

  v_payment_id := payment_api_pack.create_payment(p_from_client_id => null
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin
  
  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => null
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin

  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => null
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin

  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => -1
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin

  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => null
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка создания платежа
declare
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;
  v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                         ,t_payment_detail(2,'199.8.57.867')
                                                                         ,t_payment_detail(3,'пополнение через терминал') 
                                                                         ); 
  v_payment_id       payment.payment_id%type;
begin

  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => null
                                                 ,p_payment_detail => v_payment_detail);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка сброса платежа
declare
  v_payment_id    payment.payment_id%type              := 42;
  v_reason        payment.status_change_reason%type    := 'Тестовый сброс платежа';
begin
  payment_api_pack.fail_payment(p_payment_id => null
                               ,p_reason     => v_reason);
                               
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Сброс платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка сброса платежа
declare
  v_payment_id    payment.payment_id%type              := 42;
  v_reason        payment.status_change_reason%type    := 'Тестовый сброс платежа';
begin
  payment_api_pack.fail_payment(p_payment_id => v_payment_id
                               ,p_reason     => null);
                               
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Сброс платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка отмены платежа
declare  
  v_payment_id    payment.payment_id%type              := 42;
  v_reason        payment.status_change_reason%type    := 'Тестовая отмена платежа';
begin
  payment_api_pack.cancel_payment(p_payment_id => null
                                 ,p_reason     => v_reason);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Отмена платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка отмены платежа
declare  
  v_payment_id    payment.payment_id%type              := 42;
  v_reason        payment.status_change_reason%type    := 'Тестовая отмена платежа';
begin
  payment_api_pack.cancel_payment(p_payment_id => v_payment_id
                                 ,p_reason     => null);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Отмена платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка успешного завершения платежа
declare
  v_payment_id payment.payment_id%type := 42;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => null);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Успешное завершение платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка добавления/изменения данных по платежу
declare
  v_payment_id payment.payment_id%type    := 42;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => null
                                                         ,p_payment_detail => v_payment_detail);
                                                         
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Добавление/изменение данных по платежу. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка добавления/изменения данных по платежу
declare
  v_payment_id payment.payment_id%type    := 42;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id
                                                         ,p_payment_detail => null);
                                                         
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Добавление/изменение данных по платежу. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка удаления деталей платежа
declare
  v_payment_id payment.payment_id%type := 42;
  v_delete_field_ids t_number_array    := t_number_array(1, 2);
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id       => null
                                               ,p_delete_field_ids => v_delete_field_ids);
                                               
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Проверка удаления деталей платежа
declare
  v_payment_id payment.payment_id%type := 42;
  v_delete_field_ids t_number_array    := t_number_array(1, 2);
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id       => v_payment_id
                                               ,p_delete_field_ids => null);
                                               
  raise_application_error(-20999, 'Unit-тест или API выполнены неверно');

exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/

--Негативные тесты (триггеры)

--Проверка запрета удаления платежа через delete
declare
  v_payment_id payment.payment_id%type := 0;
begin
  
  delete from payment p 
  where p.payment_id = v_payment_id;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  
exception
  when common_pack.e_delete_forbidden then
    dbms_output.put_line('Удаление платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/


--Проверка запрета вставки в payment не через API
declare
  v_payment_id    payment.payment_id%type       := 121;
  v_from_client_id   client.client_id%type      := 1;
  v_to_client_id     client.client_id%type      := 2;
  v_summa            payment.summa%type         := 1000;
  v_currency_id      currency.currency_id%type  := 643;--Рубль
  v_create_dtime     timestamp                  := systimestamp;

begin
  
  insert into payment(payment_id
                     ,create_dtime
                     ,summa
                     ,currency_id
                     ,from_client_id
                     ,to_client_id
                     )
  values (v_payment_id,v_create_dtime,v_summa,v_currency_id,v_from_client_id,v_to_client_id);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка в таблицу payment не через API. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

--Проверка запрета обновления в payment не через API
declare
  v_payment_id    payment.payment_id%type       := 121;
  v_summa            payment.summa%type         := 15;

begin
  
  update payment p
     set p.summa = v_summa
   where p.payment_id = v_payment_id;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы payment не через API. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

--Проверка запрета вставки в payment_detail не через API
declare
  v_payment_id    payment.payment_id%type       := 0;
  v_field_id      payment_detail.field_id%type  := 0;

begin
  
  insert into payment_detail(payment_id
                            ,field_id
                            ,field_value
                            )
  values (v_payment_id,v_field_id,null);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка в таблицу payment_detail не через API. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

--Проверка запрета обновления в payment_detail не через API
declare
  v_payment_id    payment.payment_id%type           := 0;
  v_field_value   payment_detail.field_value%type   := '0';

begin
  
  update payment_detail pd
     set pd.field_value = v_field_value
   where pd.payment_id = v_payment_id;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы payment_detail не через API. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

--Проверка запрета удаления из payment_detail не через API
declare
  v_payment_id    payment.payment_id%type  := 0;

begin
  
  delete from payment_detail pd
   where pd.payment_id = v_payment_id;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Удаление из таблицы payment_detail не через API. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/
