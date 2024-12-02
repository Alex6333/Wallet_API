create or replace package body ut_payment_detail_api_pack is

  --Проверка добавления/изменения данных по платежу
  procedure insert_or_update_payment_detail is
    v_client_IP            payment_detail.field_value%type := ut_common_pack.get_random_client_IP();
    v_payment_detail       t_payment_detail_array          := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id
                                                                                                     ,v_client_IP)                                                                
                                                                                                     );
    v_client_IP_after_test payment_detail.field_value%type;
  begin
    
    --вызов тестируемой ф-ции
    payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => ut_common_pack.g_payment_id
                                                           ,p_payment_detail => v_payment_detail);
                                                           
    --получаем данные
    v_client_IP_after_test := ut_common_pack.get_payment_field_value(ut_common_pack.g_payment_id
                                                                    ,ut_common_pack.c_payment_detail_client_IP_id);
    --проверяем условие теста
    ut.expect(v_client_IP_after_test).to_equal(v_client_IP);
    
  end insert_or_update_payment_detail;
  
  --Проверка удаления деталей платежа
  procedure delete_payment_detail is
    v_delete_field_ids      t_number_array                   := t_number_array(ut_common_pack.c_payment_detail_client_software_id
                                                                              ,ut_common_pack.c_payment_detail_client_IP_id);
    v_after_client_software payment_detail.field_value%type;
    v_after_client_IP       payment_detail.field_value%type;
  begin
    
    --вызов тестируемой ф-ции
    payment_detail_api_pack.delete_payment_detail(p_payment_id       => ut_common_pack.g_payment_id
                                                 ,p_delete_field_ids => v_delete_field_ids);
                                                 
    --получаем данные
    v_after_client_software := ut_common_pack.get_payment_field_value(ut_common_pack.g_payment_id
                                                                     ,ut_common_pack.c_payment_detail_client_software_id);
    v_after_client_IP := ut_common_pack.get_payment_field_value(ut_common_pack.g_payment_id
                                                               ,ut_common_pack.c_payment_detail_client_IP_id);
                                                               
    --проверяем условие теста
    ut.expect(v_after_client_software).to_be_null();
    ut.expect(v_after_client_IP).to_be_null();
         
  end delete_payment_detail;
  
  --Проверка функционала по глобальному разрешению. Операция изменения данных платежа
  procedure direct_update_payment_detail_with_enable_manual_change is
  begin
    
    ut_common_pack.g_payment_id := ut_common_pack.c_non_existing_payment_id;
    
    common_pack.enable_manual_changes();
    
    update payment_detail pd
       set pd.field_value = pd.field_value
     where pd.payment_id = ut_common_pack.g_payment_id;
    
    common_pack.disable_manual_changes();
  
  exception
    when others then
      common_pack.disable_manual_changes();
	  raise;
  end direct_update_payment_detail_with_enable_manual_change;
  
---- Негативные тесты
  --Проверка добавления/изменения данных по платежу с пустым параметром ID платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_empty_payment_id_should_fail is
    v_client_IP      payment_detail.field_value%type := ut_common_pack.get_random_client_IP();
    v_payment_detail t_payment_detail_array          := t_payment_detail_array(t_payment_detail(ut_common_pack.c_payment_detail_client_IP_id
                                                                                               ,v_client_IP)                                                                
                                                                                               );
  begin
    
    ut_common_pack.g_payment_id := null;
        
    payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => ut_common_pack.g_payment_id
                                                           ,p_payment_detail => v_payment_detail);

  end insert_or_update_payment_detail_with_empty_payment_id_should_fail;
  
  --Проверка добавления/изменения данных по платежу с пустым параметром детали платежа завершается ошибкой
  procedure insert_or_update_payment_detail_with_empty_payment_detail_should_fail is
    v_payment_detail t_payment_detail_array  := null;
  begin
    
    payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => ut_common_pack.g_payment_id
                                                           ,p_payment_detail => v_payment_detail);

  end insert_or_update_payment_detail_with_empty_payment_detail_should_fail;
  
  --Проверка удаления деталей платежа с пустым параметром ID платежа завершается ошибкой
  procedure delete_payment_detail_with_empty_payment_id_should_fail is
    v_delete_field_ids t_number_array          := t_number_array(ut_common_pack.c_payment_detail_client_software_id
                                                                ,ut_common_pack.c_payment_detail_client_IP_id);
  begin
    
    ut_common_pack.g_payment_id := null;
    
    payment_detail_api_pack.delete_payment_detail(p_payment_id       => ut_common_pack.g_payment_id
                                                 ,p_delete_field_ids => v_delete_field_ids);

  end delete_payment_detail_with_empty_payment_id_should_fail;
  
  --Проверка удаления деталей платежа с пустым параметром детали платежа завершается ошибкой
  procedure delete_payment_detail_with_empty_payment_detail_should_fail is
    v_delete_field_ids t_number_array          := null;
  begin
    
    payment_detail_api_pack.delete_payment_detail(p_payment_id       => ut_common_pack.g_payment_id
                                                 ,p_delete_field_ids => v_delete_field_ids);

  end delete_payment_detail_with_empty_payment_detail_should_fail;
  
----Негативные тесты (триггеры)
  --Проверка запрета вставки в payment_detail не через API завершается ошибкой
  procedure direct_insert_payment_detail_should_fail is
    v_field_id      payment_detail.field_id%type  := ut_common_pack.c_payment_detail_client_software_id;
  begin
    
    ut_common_pack.g_payment_id := ut_common_pack.c_non_existing_payment_id;
    
    insert into payment_detail(payment_id
                              ,field_id
                              ,field_value
                              )
    values (ut_common_pack.g_payment_id,v_field_id,null);
  
  end direct_insert_payment_detail_should_fail;
  
  --Проверка запрета обновления в payment_detail не через API завершается ошибкой
  procedure direct_update_payment_detail_should_fail is
    v_field_id      payment_detail.field_id%type      := ut_common_pack.c_payment_detail_client_IP_id;
    v_field_value   payment_detail.field_value%type   := ut_common_pack.get_random_client_IP();

  begin
    
    ut_common_pack.g_payment_id := ut_common_pack.c_non_existing_payment_id;
    
    update payment_detail pd
       set pd.field_value = v_field_value
     where pd.payment_id  = ut_common_pack.g_payment_id
       and pd.field_id    = v_field_id;

  end direct_update_payment_detail_should_fail;

  --Проверка запрета удаления из payment_detail не через API завершается ошибкой
  procedure direct_delete_payment_detail_should_fail is
  begin
    
    ut_common_pack.g_payment_id := ut_common_pack.c_non_existing_payment_id;
    
    delete from payment_detail pd
     where pd.payment_id = ut_common_pack.g_payment_id;

  end direct_delete_payment_detail_should_fail;

end ut_payment_detail_api_pack;
/