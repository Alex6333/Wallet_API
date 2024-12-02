create or replace package body ut_common_pack is

  ----Функционал для создания клиента
  
  --Генерация значения полей для сущности клиент
  function get_random_client_email return client_data.field_value%type is
  begin
    return dbms_random.string('l', 10) || '@' || dbms_random.string('l',
                                                                    10) || '.com';
  end get_random_client_email;

  function get_random_client_mobile_phone return client_data.field_value%type is
  begin
    return '+7' || trunc(dbms_random.value(79000000000, 79999999999));
  end get_random_client_mobile_phone;

  function get_random_client_inn return client_data.field_value%type is
  begin
    return trunc(dbms_random.value(1000000000000, 99999999999999));
  end get_random_client_inn;

  function get_random_client_bday return client_data.field_value%type is
  begin
    return add_months(trunc(sysdate),
                      -trunc(dbms_random.value(18 * 12, 50 * 12)));
  end get_random_client_bday;
  
  --Создание клиента
  function create_default_client(p_client_data t_client_data_array := null)
    return client.client_id%type is
    v_client_data t_client_data_array := p_client_data;
  begin
    --если ничего не передано, то по умолчанию генерим какие-то значения
    if v_client_data is null
       or v_client_data is empty then
      v_client_data := t_client_data_array(t_client_data(c_client_data_field_email_id,
                                                         get_random_client_email()),
                                           t_client_data(c_client_data_mobile_phone_id,
                                                         get_random_client_mobile_phone()),
                                           t_client_data(c_client_data_inn_id,
                                                         get_random_client_inn()),
                                           t_client_data(c_client_data_birthday_id,
                                                         get_random_client_bday()));
    end if;
  
    return client_api_pack.create_client(p_client_data => v_client_data);
  end create_default_client;
  
  function get_client_info(p_client_id client_data.client_id%type)
    return client%rowtype is
    v_client client%rowtype;
  begin
    select * into v_client 
		  from client c 
		 where c.client_id = p_client_id;
    return v_client;
  end get_client_info;
  
  function get_client_field_value(p_client_id client_data.client_id%type
                                 ,p_field_id  client_data.field_id%type)
    return client_data.field_value%type is
    v_field_value client_data.field_value%type;
  begin
    select max(cd.field_value)
      into v_field_value
      from client_data cd
     where cd.client_id = p_client_id
       and cd.field_id = p_field_id;
  
    return v_field_value;
  end get_client_field_value;

  ----Функционал для создания платежа
  
  --Генерация значения полей для сущности платеж
  function get_random_payment_summa return payment.summa%type is
  begin
    return trunc(dbms_random.value(10000,9999999));
  end get_random_payment_summa;
    
  function get_random_payment_create_dtime return payment.create_dtime%type is
  begin
    return (sysdate - dbms_random.value(18 * 12, 50 * 12));
  end get_random_payment_create_dtime;
    
  function get_random_client_IP return payment_detail.field_value%type is
  begin
    return to_char(trunc(dbms_random.value(100,999)) || '.' || 
           trunc(dbms_random.value(0,9)) || '.' ||
           trunc(dbms_random.value(10,99)) || '.' ||
           trunc(dbms_random.value(100,999)));
  end get_random_client_IP;
  
  function get_random_is_check_frod return payment_detail.field_value%type is
  begin
    return case  
           when trunc(dbms_random.value(0,3)) = 1 then 'Y'
           else 'N' end;
  end get_random_is_check_frod;
  
  function get_random_currency_id return payment_detail.field_value%type is
  begin
    return case trunc(dbms_random.value(0,4))
           when 1 then 840
           when 2 then 978
           else 643 end;
  end get_random_currency_id;
  
  function get_random_client_software return payment_detail.field_value%type is
  begin
    return dbms_random.string('a', 100);
  end get_random_client_software;
  
  function get_random_payment_note return payment_detail.field_value%type is
  begin
    return dbms_random.string('a', 100);
  end get_random_payment_note;
  
  --Создание платежа
  function create_default_payment(p_from_client_id   client.client_id%type     := null 
                                 ,p_to_client_id     client.client_id%type     := null  
                                 ,p_summa            payment.summa%type        := null 
                                 ,p_currency_id      currency.currency_id%type := null 
                                 ,p_create_dtime     timestamp                 := null 
                                 ,p_payment_detail   t_payment_detail_array    := null 
                                  )
    return payment.payment_id%type is
    
    v_from_client_id   client.client_id%type      := p_from_client_id;
    v_to_client_id     client.client_id%type      := p_to_client_id ; 
    v_summa            payment.summa%type         := p_summa;         
    v_currency_id      currency.currency_id%type  := p_currency_id;  
    v_create_dtime     timestamp                  := p_create_dtime;  
    v_payment_detail   t_payment_detail_array     := p_payment_detail; 
    
  begin
    
    --если ничего не передано, то по умолчанию генерим какие-то значения
    if v_from_client_id is null then
      v_from_client_id := create_default_client();
    end if;
    if v_to_client_id is null then
      v_to_client_id := create_default_client();
    end if;
    if v_summa is null then
      v_summa := get_random_payment_summa();
    end if;
    if v_currency_id is null then
      v_currency_id := get_random_currency_id();
    end if;
    if v_create_dtime is null then
      v_create_dtime := get_random_payment_create_dtime();
    end if;
    if v_payment_detail is null 
       or v_payment_detail is empty then
      v_payment_detail := t_payment_detail_array(t_payment_detail(c_payment_detail_client_software_id,
                                                                  get_random_client_software()),
                                                 t_payment_detail(c_payment_detail_client_IP_id,
                                                                  get_random_client_IP()),
                                                 t_payment_detail(c_payment_detail_payment_note_id,
                                                                  get_random_payment_note()),
                                                 t_payment_detail(c_payment_detail_payment_is_checked_frod_id,
                                                                  get_random_is_check_frod()));
    end if;
    
    return payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                          ,p_to_client_id   => v_to_client_id
                                          ,p_summa          => v_summa
                                          ,p_currency_id    => v_currency_id
                                          ,p_create_dtime   => v_create_dtime
                                          ,p_payment_detail => v_payment_detail);
                                          
  end create_default_payment;
  
  --Создание платежа с параметрами
  function create_default_payment_with_param(p_from_client_id   client.client_id%type     := create_default_client() 
                                            ,p_to_client_id     client.client_id%type     := create_default_client()  
                                            ,p_summa            payment.summa%type        := get_random_payment_summa() 
                                            ,p_currency_id      currency.currency_id%type := get_random_currency_id() 
                                            ,p_create_dtime     timestamp                 := get_random_payment_create_dtime() 
                                            ,p_payment_detail   t_payment_detail_array    := t_payment_detail_array(t_payment_detail(c_payment_detail_client_software_id,
                                                                                                                                     get_random_client_software()),
                                                                                                                    t_payment_detail(c_payment_detail_client_IP_id,
                                                                                                                                     get_random_client_IP()),
                                                                                                                    t_payment_detail(c_payment_detail_payment_note_id,
                                                                                                                                     get_random_payment_note()),
                                                                                                                    t_payment_detail(c_payment_detail_payment_is_checked_frod_id,
                                                                                                                                     get_random_is_check_frod())) 
                                  )
    return payment.payment_id%type is
    
    v_from_client_id   client.client_id%type      := p_from_client_id;
    v_to_client_id     client.client_id%type      := p_to_client_id ; 
    v_summa            payment.summa%type         := p_summa;         
    v_currency_id      currency.currency_id%type  := p_currency_id;  
    v_create_dtime     timestamp                  := p_create_dtime;  
    v_payment_detail   t_payment_detail_array     := p_payment_detail; 
    
  begin
    
    return payment_api_pack.create_payment(p_from_client_id => v_from_client_id
                                          ,p_to_client_id   => v_to_client_id
                                          ,p_summa          => v_summa
                                          ,p_currency_id    => v_currency_id
                                          ,p_create_dtime   => v_create_dtime
                                          ,p_payment_detail => v_payment_detail);
                                          
  end create_default_payment_with_param;
  
  --Получить информацию по сущности "Платеж"
  function get_payment_info(p_payment_id payment.payment_id%type)
    return payment%rowtype is
    v_payment payment%rowtype;
  begin
    select *
      into v_payment
      from payment p
     where p.payment_id = p_payment_id;
     
    return v_payment;
  end get_payment_info;
  
  --Получить данные по полю платежа
  function get_payment_field_value(p_payment_id payment_detail.payment_id%type
                                  ,p_field_id   payment_detail.field_id%type)
    return payment_detail.field_value%type is
    v_field_value payment_detail.field_value%type;
  begin
    select max(pd.field_value)
      into v_field_value
      from payment_detail pd
     where pd.payment_id = p_payment_id
       and pd.field_id = p_field_id;
    
    return v_field_value;
  end get_payment_field_value;
  
  --Возбуждение исключения о неверном тесте
  procedure ut_failed is
  begin
    raise_application_error(c_error_code_test_failed,
                            c_error_msg_test_failed);
  end ut_failed;

  ----Вспомогательные процедуры
  
  --Создание платежа
  procedure create_default_payment is
  begin
    g_payment_id := ut_common_pack.create_default_payment();
  end create_default_payment;
    
end ut_common_pack;
/