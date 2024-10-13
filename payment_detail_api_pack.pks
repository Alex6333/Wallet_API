create or replace package payment_detail_api_pack is

  /*
  Автор: Куликов А.А.
  Описание: API для сущности "Детали платежа"
  */
  
  -- Сообщения ошибок
  c_error_msg_empty_field_id     constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value  constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection   constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_payment_id   constant varchar2(100 char) := 'ID платежа не может быть пустым';  
  
  --Добавление/изменение данных по платежу
  procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type
                                            ,p_payment_detail t_payment_detail_array);
  
  --Удаление данных по деталям платежа
  procedure delete_payment_detail (p_payment_id payment.payment_id%type
                                  ,p_delete_field_ids t_number_array);  
                                                  
end payment_detail_api_pack;
/