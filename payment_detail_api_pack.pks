create or replace package payment_detail_api_pack is

  /*
  Автор: Куликов А.А.
  Описание: API для сущности "Детали платежа"
  */
  
  --Сообщения ошибок
  c_error_msg_manual_changes            constant varchar2(100 char) := 'Изменения должны выполняться через API';
  
  --Коды ошибок
  c_error_code_manual_changes          constant number(10) := -20103;
  
  --Объекты ошибок
  e_manual_changes exception;
  pragma exception_init(e_manual_changes, c_error_code_manual_changes);
  
  --Добавление/изменение данных по платежу
  procedure insert_or_update_payment_detail (p_payment_id      payment.payment_id%type
                                            ,p_payment_detail  t_payment_detail_array);
  
  --Удаление данных по деталям платежа
  procedure delete_payment_detail (p_payment_id        payment.payment_id%type
                                  ,p_delete_field_ids  t_number_array); 
                                  
  --Выполняются ли изменения через API
  procedure is_changes_through_api; 
                                                  
end payment_detail_api_pack;