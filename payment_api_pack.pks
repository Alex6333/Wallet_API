create or replace package payment_api_pack is

  /*
  Автор: Куликов А.А.
  Описание: API для сущности "Платеж"
  */
  
  --Статусы изменения состояния платежа
  c_create  constant payment.status%type := 0;
  c_success constant payment.status%type := 1;
  c_error   constant payment.status%type := 2;
  c_cancel  constant payment.status%type := 3;
  
  ----API
  
  --Создание платежа
  function create_payment(p_from_client_id  client.client_id%type
                         ,p_to_client_id    client.client_id%type
                         ,p_summa           payment.summa%type
                         ,p_currency_id     currency.currency_id%type
                         ,p_create_dtime    timestamp
                         ,p_payment_detail  t_payment_detail_array)
    return payment.payment_id%type;
  
  --Сброс платежа
  procedure fail_payment (p_payment_id  payment.payment_id%type
                         ,p_reason      payment.status_change_reason%type);
  
  --Отмена платежа
  procedure cancel_payment (p_payment_id  payment.payment_id%type
                           ,p_reason      payment.status_change_reason%type);
  
  --Успешный платеж
  procedure successful_finish_payment (p_payment_id payment.payment_id%type);
  
  ----Триггеры
  
  --Выполняются ли изменения через API
  procedure is_changes_through_api;
  
  --Проверка на возможность удалять платежи
  procedure check_payment_delete_restriction;
  
end payment_api_pack;
/