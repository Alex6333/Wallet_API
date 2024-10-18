create or replace package payment_detail_api_pack is

  /*
  Автор: Куликов А.А.
  Описание: API для сущности "Детали платежа"
  */
  
  --Добавление/изменение данных по платежу
  procedure insert_or_update_payment_detail (p_payment_id      payment.payment_id%type
                                            ,p_payment_detail  t_payment_detail_array);
  
  --Удаление данных по деталям платежа
  procedure delete_payment_detail (p_payment_id        payment.payment_id%type
                                  ,p_delete_field_ids  t_number_array);  
                                                  
end payment_detail_api_pack;