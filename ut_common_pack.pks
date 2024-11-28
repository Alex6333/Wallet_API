create or replace package ut_common_pack is

  -- Author  : Куликов А.А.
  -- Purpose : Общий пакет для организации unit-тестов
  
  c_client_data_field_email_id                constant client_data_field.field_id%type := 1;
  c_client_data_mobile_phone_id               constant client_data_field.field_id%type := 2;
  c_client_data_inn_id                        constant client_data_field.field_id%type := 3;
  c_client_data_birthday_id                   constant client_data_field.field_id%type := 4;
  
  c_non_existing_payment_id                   constant payment.payment_id%type         := -111;
  
  c_payment_detail_client_software_id         constant payment_detail.field_id%type    := 1;
  c_payment_detail_client_IP_id               constant payment_detail.field_id%type    := 2;
  c_payment_detail_payment_note_id            constant payment_detail.field_id%type    := 3;
  c_payment_detail_payment_is_checked_frod_id constant payment_detail.field_id%type    := 4;
  
  c_payment_currency_id_rub                   constant payment.currency_id%type        := 643;--Рубль
  c_payment_detail_default_client_software    constant payment_detail.field_value%type := 'internal terminal';
  c_payment_detail_default_payment_note       constant payment_detail.field_value%type := 'пополнение через терминал';
  c_payment_detail_default_is_checked_frod    constant payment_detail.field_value%type := 'Y';
  
  --Сообщения об ошибках
  c_error_msg_test_failed constant varchar2(100 char) := 'Unit-тест не прошел';

  --Коды ошибок
  c_error_code_test_failed constant number(10) := -20999;

  --Генерация значения полей для сущности клиент
  function get_random_client_email        return client_data.field_value%type;
  function get_random_client_mobile_phone return client_data.field_value%type;
  function get_random_client_inn          return client_data.field_value%type;
  function get_random_client_bday         return client_data.field_value%type;

  --Создание клиента
  function create_default_client(p_client_data t_client_data_array := null)
    return client.client_id%type;
  
  -- Получить информацию по сущности "Клиент"
  function get_client_info(p_client_id client_data.client_id%type)
    return client%rowtype;

  -- Получить данные по полю клиента
  function get_client_field_value(p_client_id client_data.client_id%type
                                 ,p_field_id  client_data.field_id%type)
    return client_data.field_value%type;
    
  --Генерация значения полей для сущности платеж
  function get_random_payment_summa        return payment.summa%type;
  function get_random_payment_create_dtime return payment.create_dtime%type;
  function get_random_client_IP            return payment_detail.field_value%type;
  
  --Создание платежа
  function create_default_payment(p_from_client_id   client.client_id%type     := null 
                                 ,p_to_client_id     client.client_id%type     := null  
                                 ,p_summa            payment.summa%type        := null 
                                 ,p_currency_id      currency.currency_id%type := null 
                                 ,p_create_dtime     timestamp                 := null 
                                 ,p_payment_detail   t_payment_detail_array    := null
                                  )
    return payment.payment_id%type;
  
  --Получить информацию по сущности "Платеж"
  function get_payment_info(p_payment_id payment.payment_id%type)
    return payment%rowtype;
  
  --Получить данные по полю платежа
  function get_payment_field_value(p_payment_id payment_detail.payment_id%type
                                  ,p_field_id   payment_detail.field_id%type)
    return payment_detail.field_value%type;
    
  --Возбуждение исключения о неверном тесте
  procedure ut_failed;

end ut_common_pack;
/