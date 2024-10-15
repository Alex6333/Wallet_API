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
  
  --Сообщения ошибок
  c_error_msg_empty_field_id       constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value    constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection     constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_payment_id     constant varchar2(100 char) := 'ID платежа не может быть пустым';
  c_error_msg_empty_reason         constant varchar2(100 char) := 'Причина не может быть пустой';
  
  
  --Создание платежа
  function create_payment(p_from_client_id client.client_id%type
                         ,p_to_client_id client.client_id%type
                         ,p_summa payment.summa%type
                         ,p_currency_id currency.currency_id%type
                         ,p_create_dtime timestamp
                         ,p_payment_detail t_payment_detail_array)
    return payment.payment_id%type;
  
  --Сброс платежа
  procedure fail_payment (p_payment_id payment.payment_id%type
                         ,p_reason payment.status_change_reason%type);
  
  --Отмена платежа
  procedure cancel_payment (p_payment_id payment.payment_id%type
                           ,p_reason payment.status_change_reason%type);
  
  --Успешный платеж
  procedure successful_finish_payment (p_payment_id payment.payment_id%type);
  
end;
