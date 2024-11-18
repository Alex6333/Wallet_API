create or replace package body ut_payment_api_pack is

  procedure create_payment is
    v_payment_id        payment.payment_id%type;
    v_payment           payment%rowtype;
  begin
    --вызов тестируемой ф-ции
    v_payment_id := ut_common_pack.create_default_payment();
    
    --получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(v_payment_id);
    
    --проверка правильного заполнения полей
    if v_payment.status != payment_api_pack.c_create
      or v_payment.status_change_reason is not null then
      ut_common_pack.ut_failed();      
    end if;
    
    --проверка работы триггера на заполенние тех. дат
    if v_payment.create_dtime_tech != v_payment.update_dtime_tech then
      ut_common_pack.ut_failed();  
    end if;

  end create_payment;
  
  --Проверка сброса платежа
  procedure fail_payment is
    v_payment_id        payment.payment_id%type;
    v_reason            payment.status_change_reason%type := dbms_random.string('a', 100);
    v_payment           payment%rowtype;
  begin
    
    --setup
    v_payment_id := ut_common_pack.create_default_payment();
    
    --Вызов тестируемой ф-ции
    payment_api_pack.fail_payment(p_payment_id => v_payment_id
                                 ,p_reason     => v_reason);
    
    --Получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(v_payment_id);
    
    --проверка правильного заполнения полей
    if v_payment.status != payment_api_pack.c_error
      or v_payment.status_change_reason != v_reason then
      ut_common_pack.ut_failed();      
    end if;
    
    --проверка работы триггера по изменению тех.дат
    if v_payment.create_dtime_tech = v_payment.update_dtime_tech then
      ut_common_pack.ut_failed();   
    end if;
    
  end fail_payment;
  
  --Проверка отмены платежа
  procedure cancel_payment is
    v_payment_id payment.payment_id%type;
    v_reason     payment.status_change_reason%type := dbms_random.string('a', 100);
    v_payment    payment%rowtype;
  begin
    
    --setup
    v_payment_id := ut_common_pack.create_default_payment();
    
    --Вызов тестируемой ф-ции
    payment_api_pack.cancel_payment(p_payment_id => v_payment_id
                                   ,p_reason     => v_reason);
    
    --Получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(v_payment_id);
    
    --проверка правильного заполнения полей
    if v_payment.status != payment_api_pack.c_cancel
      or v_payment.status_change_reason != v_reason then
      ut_common_pack.ut_failed();      
    end if;
    
    --проверка работы триггера по изменению тех.дат
    if v_payment.create_dtime_tech = v_payment.update_dtime_tech then
      ut_common_pack.ut_failed();   
    end if;
    
  end cancel_payment;
  
  --Проверка успешного завершения платежа
  procedure successful_finish_payment is
    v_payment_id payment.payment_id%type;
    v_payment    payment%rowtype;
  begin
    
    --setup
    v_payment_id := ut_common_pack.create_default_payment();
    
    --Вызов тестируемой ф-ции
    payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
    
    --Получаем данные по платежу
    v_payment := ut_common_pack.get_payment_info(v_payment_id);
    
    --проверка правильного заполнения полей
    if v_payment.status != payment_api_pack.c_success
      or v_payment.status_change_reason is not null then
      ut_common_pack.ut_failed();      
    end if;
    
    --проверка работы триггера по изменению тех.дат
    if v_payment.create_dtime_tech = v_payment.update_dtime_tech then
      ut_common_pack.ut_failed();   
    end if;
    
  end successful_finish_payment;
  
  --Проверка функционала по глобальному разрешению. Операция удаления платежа
  procedure delete_payment_with_direct_dml_and_enabled_manual_changes is
    v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
  begin
    common_pack.enable_manual_changes();
        
    delete from payment p where p.payment_id = v_payment_id;
    
    common_pack.disable_manual_changes();
    
  exception
    when others then
      common_pack.disable_manual_changes();
      raise;    
  end delete_payment_with_direct_dml_and_enabled_manual_changes;
  
  -- Проверка функционала по глобальному разрешению. Операция изменения платежа
  procedure update_payment_with_direct_dml_and_enabled_manual_changes is
    v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    v_summa      payment.summa%type      := ut_common_pack.get_random_payment_summa;
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
  end update_payment_with_direct_dml_and_enabled_manual_changes;

---- Негативные тесты
  
  --Проверка создания платежа с пустым набором деталей платежа завершается ошибкой
  procedure create_payment_with_empty_payment_detail_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime; 
    v_payment_detail   t_payment_detail_array     := null;
    v_payment_id       payment.payment_id%type;
  begin
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end create_payment_with_empty_payment_detail_should_fail;
  
  --Проверка создания платежа с пустым параметром валюты платежа завершается ошибкой
  procedure create_payment_with_empty_currency_id_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := null;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id,
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod)); 
    v_payment_id       payment.payment_id%type;
  begin
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end create_payment_with_empty_currency_id_should_fail;
  
  --Проверка создания платежа с пустым параметром суммы платежа завершается ошибкой
  procedure create_payment_with_empty_summa_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := null;
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id, 
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),                      
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod));                       
                                                                           
    v_payment_id       payment.payment_id%type;
  begin
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end create_payment_with_empty_summa_should_fail;
  
  --Проверка создания платежа с пустым параметром получателя платежа платежа завершается ошибкой
  procedure create_payment_with_empty_client_to_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := null;
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id, 
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),                      
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod));                       
                                                                           
    v_payment_id       payment.payment_id%type;
  begin
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end create_payment_with_empty_client_to_should_fail;
  
  --Проверка создания платежа с пустым параметром отправителя платежа платежа завершается ошибкой
  procedure create_payment_with_empty_client_from_should_fail is
    v_from_client_id   client.client_id%type      := null;
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id, 
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),                      
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod));                       
                                                                           
    v_payment_id       payment.payment_id%type;
  begin
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end create_payment_with_empty_client_from_should_fail;
  
  --Проверка создания платежа с отрицательной суммой завершается ошибкой
  procedure create_payment_with_negative_payment_summa_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := -ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id, 
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),                      
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod));                       
                                                                           
    v_payment_id       payment.payment_id%type;
  begin

    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
    
    ut_common_pack.ut_failed();

  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end create_payment_with_negative_payment_summa_should_fail;
  
  --Проверка сброса платежа с пустым параметром ID платежа завершается ошибкой
  procedure fail_payment_with_empty_payment_id_should_fail is
    v_payment_id    payment.payment_id%type           := null;
    v_reason        payment.status_change_reason%type := dbms_random.string('a', 100);
  begin
    payment_api_pack.fail_payment(p_payment_id => v_payment_id
                                 ,p_reason     => v_reason);
                                 
    ut_common_pack.ut_failed();

  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end fail_payment_with_empty_payment_id_should_fail;
  
  --Проверка сброса платежа с пустым параметром причины изменения статуса платежа завершается ошибкой
  procedure fail_payment_with_empty_reason_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id, 
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),                      
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod));                       
                                                                           
    v_payment_id       payment.payment_id%type;
    v_reason           payment.status_change_reason%type := null;
  begin
    
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
                                                     
    payment_api_pack.fail_payment(p_payment_id => v_payment_id
                                 ,p_reason     => v_reason);
                                 
    ut_common_pack.ut_failed();

  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end fail_payment_with_empty_reason_should_fail;
  
  --Проверка отмены платежа с пустым параметром ID платежа завершается ошибкой
  procedure cancel_payment_with_empty_payment_id_should_fail is
    v_payment_id    payment.payment_id%type              := null;
    v_reason        payment.status_change_reason%type    := dbms_random.string('a', 100);
  begin
    payment_api_pack.cancel_payment(p_payment_id => v_payment_id
                                   ,p_reason     => v_reason);
    
    ut_common_pack.ut_failed();

  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end cancel_payment_with_empty_payment_id_should_fail;
  
  --Проверка отмены платежа с пустым параметром причины изменения статуса платежа завершается ошибкой
  procedure cancel_payment_with_empty_reason_should_fail is
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;
    v_payment_detail   t_payment_detail_array     := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_software_id,
                                                                                             ut_common_pack.c_payment_detail_default_client_software),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id, 
                                                                                             ut_common_pack.get_random_client_IP()),
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_note_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_payment_note),                      
                                                                            t_payment_detail(ut_common_pack.c_payment_detail_payment_is_checked_frod_id,                      
                                                                                             ut_common_pack.c_payment_detail_default_is_checked_frod));                       
                                                                           
    v_payment_id       payment.payment_id%type;
    v_reason           payment.status_change_reason%type := null;
  begin
    
    v_payment_id := payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                                   ,p_to_client_id   => v_to_client_id
                                                   ,p_summa          => v_summa
                                                   ,p_currency_id    => v_currency_id
                                                   ,p_create_dtime   => v_create_dtime
                                                   ,p_payment_detail => v_payment_detail);
                                                     
    payment_api_pack.cancel_payment(p_payment_id => v_payment_id
                                   ,p_reason     => v_reason);
                                 
    ut_common_pack.ut_failed();

  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end cancel_payment_with_empty_reason_should_fail;
  
  --Проверка успешного завершения платежа с пустым параметром ID платежа завершается ошибкой
  procedure successful_finish_payment_with_empty_payment_id_should_fail is
    v_payment_id payment.payment_id%type := null;
  begin
    payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
    
    ut_common_pack.ut_failed();

  exception
    when common_pack.e_invalid_input_parameter then
      null;
  end successful_finish_payment_with_empty_payment_id_should_fail;
  
----Негативные тесты (триггеры)
  --Проверка запрета удаления платежа через прямой delete завершается ошибкой
  procedure direct_payment_delete_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
  begin
    
    delete from payment p 
    where p.payment_id = v_payment_id;
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_delete_forbidden then
      null;
  end direct_payment_delete_should_fail;
  
  --Проверка запрета вставки в payment не через API завершается ошибкой
  procedure direct_payment_insert_should_fail is
    v_payment_id       payment.payment_id%type    := ut_common_pack.c_non_existing_payment_id;
    v_from_client_id   client.client_id%type      := ut_common_pack.create_default_client();
    v_to_client_id     client.client_id%type      := ut_common_pack.create_default_client();
    v_summa            payment.summa%type         := ut_common_pack.get_random_payment_summa();
    v_currency_id      currency.currency_id%type  := ut_common_pack.c_payment_currency_id_rub;
    v_create_dtime     timestamp                  := ut_common_pack.get_random_payment_create_dtime;

  begin
    
    insert into payment(payment_id
                       ,create_dtime
                       ,summa
                       ,currency_id
                       ,from_client_id
                       ,to_client_id
                       )
    values (v_payment_id,v_create_dtime,v_summa,v_currency_id,v_from_client_id,v_to_client_id);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_manual_changes then
      null;
  end direct_payment_insert_should_fail;
  
  --Проверка запрета обновления в payment не через API завершается ошибкой
  procedure direct_payment_update_should_fail is
    v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    v_summa      payment.summa%type      := ut_common_pack.get_random_payment_summa();

  begin
    
    update payment p
       set p.summa = v_summa
     where p.payment_id = v_payment_id;
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_manual_changes then
      null;
  end direct_payment_update_should_fail;

  --Негативный unit-тест для ситуации отсутствия в таблице payment переданного платежа зфвершается ошибкой
  procedure block_non_exiting_payment_should_fail is
    v_payment_id      payment.payment_id%type  := ut_common_pack.c_non_existing_payment_id;
    v_payment_reason  payment.status_change_reason%type := dbms_random.string('a', 100);
  begin
    
    payment_api_pack.fail_payment(v_payment_id
                                 ,v_payment_reason);
    
    ut_common_pack.ut_failed();
    
  exception
    when common_pack.e_object_not_found then
      null;
  end block_non_exiting_payment_should_fail;
  
end ut_payment_api_pack;
/