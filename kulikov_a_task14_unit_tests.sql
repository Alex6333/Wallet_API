--Решение. Задание 14. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: Unit-тесты для API для сущностей "Платеж" и "Детали платежа"
*/
select t.status
      ,t.*
  from user_objects t
 where t.object_type like 'PACKAGE%';
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
begin
  v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                 ,p_to_client_id   => v_to_client_id
                                                 ,p_summa          => v_summa
                                                 ,p_currency_id    => v_currency_id
                                                 ,p_create_dtime   => v_create_dtime
                                                 ,p_payment_detail => v_payment_detail);
  
  dbms_output.put_line('ID созданного платежа: ' || v_payment_id);
  --commit;
end;
/

select * from payment p where p.payment_id = 101;
select pd.*, f.description from payment_detail pd join payment_detail_field f on f.field_id = pd.field_id where pd.payment_id = 101;
/

--Проверка сброса платежа
declare
  v_payment_id    payment.payment_id%type              := 101;
  v_reason        payment.status_change_reason%type    := 'Тестовый сброс платежа';
begin
  payment_api_pack.fail_payment(p_payment_id => v_payment_id
                               ,p_reason     => v_reason);
end;
/

select * from payment p where p.payment_id = 101;
/

--Проверка отмены платежа
declare  
  v_payment_id    payment.payment_id%type              := 101;
  v_reason        payment.status_change_reason%type    := 'Тестовая отмена платежа';
begin
  payment_api_pack.cancel_payment(p_payment_id => v_payment_id
                                 ,p_reason     => v_reason);
end;
/

select * from payment p where p.payment_id = 101;
/

--Проверка успешного завершения платежа
declare
  v_payment_id payment.payment_id%type := 101;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
end;
/

select * from payment p where p.payment_id = 101;
/

--Проверка добавления/изменения данных по платежу
declare
  v_payment_id payment.payment_id%type    := 101;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id
                                                         ,p_payment_detail => v_payment_detail);
end;
/

select pd.*, f.description from payment_detail pd join payment_detail_field f on f.field_id = pd.field_id where pd.payment_id = 101;
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

select pd.*, f.description from payment_detail pd join payment_detail_field f on f.field_id = pd.field_id where pd.payment_id = 101;
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
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
  when payment_api_pack.e_invalid_input_parameter then
    dbms_output.put_line('Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
    dbms_output.put_line(dbms_utility.format_error_backtrace);
end;
/
