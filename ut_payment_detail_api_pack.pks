create or replace package ut_payment_detail_api_pack is

  -- Author  : Куликов А.А.
  -- Purpose : Unit-тесты для API деталей платежа
  
  --%suite(Test payment_api_pack)
  
  --%test(Проверка добавления/изменения данных по платежу)
  procedure insert_or_update_payment_detail;
  
  --%test(Проверка удаления деталей платежа)
  procedure delete_payment_detail;
  
  --%test(Проверка функционала по глобальному разрешению. Операция изменения данных платежа)
  procedure direct_update_payment_detail_with_enable_manual_change;
  
  --%test(Проверка добавления/изменения данных по платежу с пустым параметром ID платежа завершается ошибкой)
  procedure insert_or_update_payment_detail_with_empty_payment_id_should_fail;
  
  --%test(Проверка добавления/изменения данных по платежу с пустым параметром детали платежа завершается ошибкой)
  procedure insert_or_update_payment_detail_with_empty_payment_detail_should_fail;
  
  --%test(Проверка удаления деталей платежа с пустым параметром ID платежа завершается ошибкой)
  procedure delete_payment_detail_with_empty_payment_id_should_fail;
  
  --%test(Проверка удаления деталей платежа с пустым параметром детали платежа завершается ошибкой)
  procedure delete_payment_detail_with_empty_payment_detail_should_fail;
  
  --%test(Проверка запрета вставки в payment_detail не через API завершается ошибкой)
  procedure direct_insert_payment_detail_should_fail;
  
  --%test(Проверка запрета обновления в payment_detail не через API завершается ошибкой)
  procedure direct_update_payment_detail_should_fail;
  
  --%test(Проверка запрета удаления из payment_detail не через API завершается ошибкой)
  procedure direct_delete_payment_detail_should_fail;

end ut_payment_detail_api_pack;
/