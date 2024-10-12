--Решение. Задание 12. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: позитивные тесты для API для сущностей "Платеж" и "Детали платежа"
*/
select t.status
      ,t.*
  from user_objects t
 where t.object_type in ('FUNCTION', 'PROCEDURE');
/

--Проверка создания платежа
declare
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                   ,t_payment_detail(2,'199.8.57.867')
                                                                   ,t_payment_detail(3,'пополнение через терминал') 
                                                                   ); 
  v_payment_id payment.payment_id%type;
begin
  v_payment_id := create_payment(p_from_client_id => 1
                                ,p_to_client_id   => 2
                                ,p_summa          => 1000
                                ,p_currency_id    => 643
                                ,p_payment_detail => v_payment_detail);
  
  dbms_output.put_line('ID созданного платежа: ' || v_payment_id);
  commit;
end;
/

select * from payment p where p.payment_id = 22;
select pd.*, f.description from payment_detail pd join payment_detail_field f on f.field_id = pd.field_id where pd.payment_id = 22;
/

--Проверка сброса платежа
declare
  v_payment_id payment.payment_id%type := 22;
begin
  fail_payment(p_payment_id => v_payment_id
              ,p_reason     => 'Тестовый сброс платежа');
end;
/

select * from payment p where p.payment_id = 22;
/

--Проверка отмены платежа
declare  
  v_payment_id payment.payment_id%type := 22;
begin
  cancel_payment(p_payment_id => v_payment_id
                ,p_reason     => 'Тестовая отмена платежа');
end;
/

select * from payment p where p.payment_id = 22;
/

--Проверка успешного завершения платежа
declare
  v_payment_id payment.payment_id%type := 22;
begin
  successful_finish_payment(p_payment_id => v_payment_id);
end;
/

select * from payment p where p.payment_id = 22;
/

--Проверка добавления/изменения данных по платежу
declare
  v_payment_id payment.payment_id%type := 22;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  insert_or_update_payment_detail(p_payment_id     => v_payment_id
                                 ,p_payment_detail => v_payment_detail);
end;
/

select pd.*, f.description from payment_detail pd join payment_detail_field f on f.field_id = pd.field_id where pd.payment_id = 22;
/

--Проверка удаления деталей платежа
declare
  v_payment_id payment.payment_id%type := 22;
  v_delete_field_ids t_number_array := t_number_array(1, 2);
begin
  delete_payment_detail(p_payment_id       => v_payment_id
                       ,p_delete_field_ids => v_delete_field_ids);
end;
/

select pd.*, f.description from payment_detail pd join payment_detail_field f on f.field_id = pd.field_id where pd.payment_id = 22;
/
