create or replace package ut_payment_detail_api_pack is

  -- Author  : Куликов А.А.
  -- Purpose : Unit-тесты для API деталей платежа
  
  --%suite(Test payment_detail_api_pack)
  --%suitepath(payment_detail)
  
  --%test(Проверка добавления/изменения данных по платежу)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  procedure insert_or_update_payment_detail;
  
  --%test(Проверка удаления деталей платежа)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  procedure delete_payment_detail;
  
  --%test(Проверка функционала по глобальному разрешению. Операция изменения данных платежа)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  procedure direct_update_payment_detail_with_enable_manual_change;
  
----Негативные тесты  
  
  --%test(Проверка добавления/изменения данных по платежу с пустым параметром ID платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
  procedure insert_or_update_payment_detail_with_empty_payment_id_should_fail;
  
  --%test(Проверка добавления/изменения данных по платежу с пустым параметром детали платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
  procedure insert_or_update_payment_detail_with_empty_payment_detail_should_fail;
  
  --%test(Проверка удаления деталей платежа с пустым параметром ID платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
  procedure delete_payment_detail_with_empty_payment_id_should_fail;
  
  --%test(Проверка удаления деталей платежа с пустым параметром детали платежа завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
  procedure delete_payment_detail_with_empty_payment_detail_should_fail;
  
  --%test(Проверка запрета вставки в payment_detail не через API завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_manual_changes)
  procedure direct_insert_payment_detail_should_fail;
  
  --%test(Проверка запрета обновления в payment_detail не через API завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_manual_changes)
  procedure direct_update_payment_detail_should_fail;
  
  --%test(Проверка запрета удаления из payment_detail не через API завершается ошибкой)
  --%beforetest(ut_common_pack.create_default_payment)
  --%aftertest(ut_common_pack.delete_default_payment)
  --%throws(common_pack.c_error_code_manual_changes)
  procedure direct_delete_payment_detail_should_fail;

end ut_payment_detail_api_pack;
/