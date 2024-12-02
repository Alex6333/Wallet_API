create or replace package body ut_payment_api_pack is

  procedure create_payment is
    v_from_client_id    client.client_id%type      := 1;
    v_to_client_id      client.client_id%type      := 2 ; 
    v_summa             payment.summa%type         := 1000;         
    v_currency_id       currency.currency_id%type  := 643;  
    v_create_dtime      timestamp                  := systimestamp;  
    v_payment_detail    t_payment_detail_array     := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                            ,t_payment_detail(2,'199.8.57.867')
                                                                            ,t_payment_detail(3,'пополнение через терминал') 
                                                                            );
    v_payment           payment%rowtype;
  begin
    --вызов тестируемой ф-ции
    ut_common_pack.g_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                                  ,p_to_client_id   => v_to_client_id
                                                                  ,p_summa          => v_summa
                                                                  ,p_currency_id    => v_currency_id
                                                                  ,p_create_dtime   => v_create_dtime
                                                                  ,p_payment_detail => v_payment_detail);
    
    --получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(ut_common_pack.g_payment_id);
    
    --проверка правильного заполнения полей
    ut.expect(v_payment.summa).to_equal(v_summa);
    ut.expect(v_payment.currency_id).to_equal(v_currency_id);
    ut.expect(v_payment.from_client_id).to_equal(v_from_client_id);
    ut.expect(v_payment.to_client_id).to_equal(v_to_client_id);
    ut.expect(v_payment.status).to_equal(payment_api_pack.c_create);
    ut.expect(v_payment.status_change_reason).to_be_null();
    
    --проверка работы триггера на заполенние тех. дат
    ut.expect(v_payment.create_dtime_tech).to_equal(v_payment.update_dtime_tech);

  end create_payment;
  
  --Проверка сброса платежа
  procedure fail_payment is
    v_reason            payment.status_change_reason%type := dbms_random.string('a', 100);
    v_payment           payment%rowtype;
  begin
    
    --Вызов тестируемой ф-ции
    payment_api_pack.fail_payment(p_payment_id => ut_common_pack.g_payment_id
                                 ,p_reason     => v_reason);
    
    --Получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(ut_common_pack.g_payment_id);
    
    --проверка правильного заполнения полей
    ut.expect(v_payment.status).to_equal(payment_api_pack.c_error);
    ut.expect(v_payment.status_change_reason).to_equal(v_reason);
    
    --проверка работы триггера по изменению тех.дат
    ut.expect(v_payment.create_dtime_tech).not_to_equal(v_payment.update_dtime_tech);
    
  end fail_payment;
  
  --Проверка отмены платежа
  procedure cancel_payment is
    v_reason     payment.status_change_reason%type := dbms_random.string('a', 100);
    v_payment    payment%rowtype;
  begin
    
    --Вызов тестируемой ф-ции
    payment_api_pack.cancel_payment(p_payment_id => ut_common_pack.g_payment_id
                                   ,p_reason     => v_reason);
    
    --Получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(ut_common_pack.g_payment_id);
    
    --проверка правильного заполнения полей
    ut.expect(v_payment.status).to_equal(payment_api_pack.c_cancel);
    ut.expect(v_payment.status_change_reason).to_equal(v_reason);
    
    --проверка работы триггера по изменению тех.дат
    ut.expect(v_payment.create_dtime_tech).not_to_equal(v_payment.update_dtime_tech);
    
  end cancel_payment;
  
  --Проверка успешного завершения платежа
  procedure successful_finish_payment is
    v_payment    payment%rowtype;
  begin
    
    --Вызов тестируемой ф-ции
    payment_api_pack.successful_finish_payment(p_payment_id => ut_common_pack.g_payment_id);
    
    --Получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(ut_common_pack.g_payment_id);
    
    --проверка правильного заполнения полей
    ut.expect(v_payment.status).to_equal(payment_api_pack.c_success);
    ut.expect(v_payment.status_change_reason).to_be_null();
    
    --проверка работы триггера по изменению тех.дат
    ut.expect(v_payment.create_dtime_tech).not_to_equal(v_payment.update_dtime_tech);
    
  end successful_finish_payment;
  
  --Проверка функционала по глобальному разрешению. Операция удаления платежа
  procedure delete_payment_with_direct_dml_and_enabled_manual_changes is
    
  begin
    
    common_pack.enable_manual_changes();
        
    delete from payment p where p.payment_id = ut_common_pack.c_non_existing_payment_id;
    
    common_pack.disable_manual_changes();
  
  exception
    when others then
      common_pack.disable_manual_changes();
	  raise;
  end delete_payment_with_direct_dml_and_enabled_manual_changes;
  
  -- Проверка функционала по глобальному разрешению. Операция изменения платежа
  procedure update_payment_with_direct_dml_and_enabled_manual_changes is
    v_summa      payment.summa%type      := ut_common_pack.get_random_payment_summa;
  begin
    
    common_pack.enable_manual_changes();
    
    update payment p
       set p.summa = v_summa
     where p.payment_id = ut_common_pack.c_non_existing_payment_id;
    
    common_pack.disable_manual_changes();
    
  exception
    when others then
      common_pack.disable_manual_changes();
	  raise;
  end update_payment_with_direct_dml_and_enabled_manual_changes;

---- Негативные тесты
  
  --Проверка создания платежа с пустым набором деталей платежа завершается ошибкой
  procedure create_payment_with_empty_payment_detail_should_fail is
    v_payment_detail   t_payment_detail_array     := null;
  begin
    ut_common_pack.g_payment_id := ut_common_pack.create_default_payment_with_param(p_payment_detail => v_payment_detail);

  end create_payment_with_empty_payment_detail_should_fail;
  
  --Проверка создания платежа с пустым параметром валюты платежа завершается ошибкой
  procedure create_payment_with_empty_currency_id_should_fail is
    v_currency_id      currency.currency_id%type  := null;
  begin
    ut_common_pack.g_payment_id := ut_common_pack.create_default_payment_with_param(p_currency_id => v_currency_id);
    
  end create_payment_with_empty_currency_id_should_fail;
  
  --Проверка создания платежа с пустым параметром суммы платежа завершается ошибкой
  procedure create_payment_with_empty_summa_should_fail is
    v_summa            payment.summa%type         := null;                      
                                                                           
  begin
    ut_common_pack.g_payment_id := ut_common_pack.create_default_payment_with_param(p_summa => v_summa);

  end create_payment_with_empty_summa_should_fail;
  
  --Проверка создания платежа с пустым параметром получателя платежа платежа завершается ошибкой
  procedure create_payment_with_empty_client_to_should_fail is
    v_to_client_id     client.client_id%type      := null;                       
                                                                           
  begin
    ut_common_pack.g_payment_id := ut_common_pack.create_default_payment_with_param(p_to_client_id => v_to_client_id);

  end create_payment_with_empty_client_to_should_fail;
  
  --Проверка создания платежа с пустым параметром отправителя платежа платежа завершается ошибкой
  procedure create_payment_with_empty_client_from_should_fail is
    v_from_client_id   client.client_id%type      := null;
                                                                            
  begin
    ut_common_pack.g_payment_id := ut_common_pack.create_default_payment_with_param(p_from_client_id => v_from_client_id);

  end create_payment_with_empty_client_from_should_fail;
  
  --Проверка создания платежа с отрицательной суммой завершается ошибкой
  procedure create_payment_with_negative_payment_summa_should_fail is
    v_summa            payment.summa%type         := -ut_common_pack.get_random_payment_summa();
                                                                               
  begin

    ut_common_pack.g_payment_id := ut_common_pack.create_default_payment_with_param(p_summa => v_summa);

  end create_payment_with_negative_payment_summa_should_fail;
  
  --Проверка сброса платежа с пустым параметром ID платежа завершается ошибкой
  procedure fail_payment_with_empty_payment_id_should_fail is
    v_reason        payment.status_change_reason%type := dbms_random.string('a', 100);
  begin    
  
    ut_common_pack.g_payment_id := null;
    
    payment_api_pack.fail_payment(p_payment_id => ut_common_pack.g_payment_id
                                 ,p_reason     => v_reason);

  end fail_payment_with_empty_payment_id_should_fail;
  
  --Проверка сброса платежа с пустым параметром причины изменения статуса платежа завершается ошибкой
  procedure fail_payment_with_empty_reason_should_fail is
    v_reason           payment.status_change_reason%type := null;
  begin
                                                     
    payment_api_pack.fail_payment(p_payment_id => ut_common_pack.g_payment_id
                                 ,p_reason     => v_reason);

  end fail_payment_with_empty_reason_should_fail;
  
  --Проверка отмены платежа с пустым параметром ID платежа завершается ошибкой
  procedure cancel_payment_with_empty_payment_id_should_fail is
    v_reason        payment.status_change_reason%type    := dbms_random.string('a', 100);
  begin
    
    ut_common_pack.g_payment_id := null;
    
    payment_api_pack.cancel_payment(p_payment_id => ut_common_pack.g_payment_id
                                   ,p_reason     => v_reason);

  end cancel_payment_with_empty_payment_id_should_fail;
  
  --Проверка отмены платежа с пустым параметром причины изменения статуса платежа завершается ошибкой
  procedure cancel_payment_with_empty_reason_should_fail is
    v_reason           payment.status_change_reason%type := null;
  begin
                                                     
    payment_api_pack.cancel_payment(p_payment_id => ut_common_pack.g_payment_id
                                   ,p_reason     => v_reason);

  end cancel_payment_with_empty_reason_should_fail;
  
  --Проверка успешного завершения платежа с пустым параметром ID платежа завершается ошибкой
  procedure successful_finish_payment_with_empty_payment_id_should_fail is
  begin
    
    ut_common_pack.g_payment_id := null;
    
    payment_api_pack.successful_finish_payment(p_payment_id => ut_common_pack.g_payment_id);

  end successful_finish_payment_with_empty_payment_id_should_fail;
  
----Негативные тесты (триггеры)
  --Проверка запрета удаления платежа через прямой delete завершается ошибкой
  procedure direct_payment_delete_should_fail is
  begin
    
    delete from payment p 
    where p.payment_id = ut_common_pack.c_non_existing_payment_id;

  end direct_payment_delete_should_fail;
  
  --Проверка запрета вставки в payment не через API завершается ошибкой
  procedure direct_payment_insert_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.get_random_currency_id();
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime();

  begin
    
    insert into payment(payment_id
                       ,create_dtime
                       ,summa
                       ,currency_id
                       ,from_client_id
                       ,to_client_id
                       )
    values (ut_common_pack.c_non_existing_payment_id,v_create_dtime,v_summa,v_currency_id,v_from_client_id,v_to_client_id);

  end direct_payment_insert_should_fail;
  
  --Проверка запрета обновления в payment не через API завершается ошибкой
  procedure direct_payment_update_should_fail is
    v_summa      payment.summa%type      := ut_common_pack.get_random_payment_summa();

  begin
    
    update payment p
       set p.summa = v_summa
     where p.payment_id = ut_common_pack.c_non_existing_payment_id;

  end direct_payment_update_should_fail;

  --Негативный unit-тест для ситуации отсутствия в таблице payment переданного платежа зфвершается ошибкой
  procedure block_non_exiting_payment_should_fail is
    v_payment_reason  payment.status_change_reason%type := dbms_random.string('a', 100);
  begin    
    
    payment_api_pack.fail_payment(ut_common_pack.c_non_existing_payment_id
                                 ,v_payment_reason);

  end block_non_exiting_payment_should_fail;
  
end ut_payment_api_pack;
/