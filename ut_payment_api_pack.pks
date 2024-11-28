create or replace package ut_payment_api_pack is

  -- Author  : Куликов А.А.
  -- Purpose : Unit-тесты для API с платежами
  
  --%suite(Test payment_api_pack)
  
  --%test(Создание платежа)
  procedure create_payment;
  
  --%test(Проверка сброса платежа)
  procedure fail_payment;
  
  --%test(Проверка отмены платежа)
  procedure cancel_payment;
  
  --%test(Проверка успешного завершения платежа)
  procedure successful_finish_payment;
  
  --%test(Проверка функционала по глобальному разрешению. Операция удаления платежа)
  procedure delete_payment_with_direct_dml_and_enabled_manual_changes;
  
  --%test(Проверка функционала по глобальному разрешению. Операция изменения платежа)
  procedure update_payment_with_direct_dml_and_enabled_manual_changes;
  
  --%test(Проверка создания платежа с пустым набором деталей платежа завершается ошибкой)
  procedure create_payment_with_empty_payment_detail_should_fail;
  
  --%test(Проверка создания платежа с пустым параметром валюты платежа завершается ошибкой)
  procedure create_payment_with_empty_currency_id_should_fail;
  
  --%test(Проверка создания платежа с пустым параметром суммы платежа завершается ошибкой)
  procedure create_payment_with_empty_summa_should_fail;
  
  --%test(Проверка создания платежа с пустым параметром получателя платежа платежа завершается ошибкой)
  procedure create_payment_with_empty_client_to_should_fail;
  
  --%test(Проверка создания платежа с пустым параметром отправителя платежа платежа завершается ошибкой)
  procedure create_payment_with_empty_client_from_should_fail;
  
  --%test(Проверка создания платежа с отрицательной суммой завершается ошибкой)
  procedure create_payment_with_negative_payment_summa_should_fail;
  
  --%test(Проверка сброса платежа с пустым параметром ID платежа завершается ошибкой)
  procedure fail_payment_with_empty_payment_id_should_fail;
  
  --%test(Проверка сброса платежа с пустым параметром причины изменения статуса платежа завершается ошибкой)
  procedure fail_payment_with_empty_reason_should_fail;
  
  --%test(Проверка отмены платежа с пустым параметром ID платежа завершается ошибкой)
  procedure cancel_payment_with_empty_payment_id_should_fail;
  
  --%test(Проверка отмены платежа с пустым параметром причины изменения статуса платежа завершается ошибкой)
  procedure cancel_payment_with_empty_reason_should_fail;
  
  --%test(Проверка успешного завершения платежа с пустым параметром ID платежа завершается ошибкой)
  procedure successful_finish_payment_with_empty_payment_id_should_fail;
  
  --%test(Проверка запрета удаления платежа через прямой delete завершается ошибкой)
  procedure direct_payment_delete_should_fail;
  
  --%test(Проверка запрета вставки в payment не через API завершается ошибкой)
  procedure direct_payment_insert_should_fail;
  
  --%test(Проверка запрета обновления в payment не через API завершается ошибкой)
  procedure direct_payment_update_should_fail;
  
  --%test(Негативный unit-тест для ситуации отсутствия в таблице payment переданного платежа зфвершается ошибкой)
  procedure block_non_exiting_payment_should_fail;
  
end ut_payment_api_pack;
/