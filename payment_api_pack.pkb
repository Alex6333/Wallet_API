create or replace package body payment_api_pack is

  g_is_api boolean := false; -- признак выполняется ли изменения через API
  
  procedure allow_changes is
  begin
    g_is_api := true;
  end allow_changes;
  
  procedure disallow_changes is
  begin
    g_is_api := false;
  end disallow_changes;
  
  --Создание платежа
  function create_payment(p_from_client_id  client.client_id%type
                         ,p_to_client_id    client.client_id%type
                         ,p_summa           payment.summa%type
                         ,p_currency_id     currency.currency_id%type
                         ,p_create_dtime    timestamp
                         ,p_payment_detail  t_payment_detail_array)
    return payment.payment_id%type
  is
    v_payment_id    payment.payment_id%type;                                                                 
    
  begin
    
    if 
      p_from_client_id is null then     
        raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_from_client_id);
    elsif 
      p_to_client_id is null then
        raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_to_client_id);
    elsif
      p_currency_id is null then
        raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_currency_id);
    elsif
      p_summa is null then
        raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_summa);
    elsif
      p_summa <= 0 then
        raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_negative_or_zero_summa);
    elsif
      p_create_dtime is null then
        raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_create_date);
    end if;
    
    allow_changes();
    
    insert into payment(payment_id
                       ,create_dtime
                       ,summa
                       ,currency_id
                       ,from_client_id
                       ,to_client_id
                       ,status)
    values(payment_seq.nextval
          ,p_create_dtime
          ,p_summa
          ,p_currency_id
          ,p_from_client_id
          ,p_to_client_id
          ,c_create)
    return payment_id into v_payment_id;
    
    payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id
                                                           ,p_payment_detail => p_payment_detail);
    
    disallow_changes();
    
    return v_payment_id;
  
  exception
    when others then
      disallow_changes();
      raise;  
  end create_payment;
  
  
  --Сброс платежа
  procedure fail_payment (p_payment_id  payment.payment_id%type
                         ,p_reason      payment.status_change_reason%type)
  is
    
  begin
    if p_payment_id is null then 
      raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_payment_id);
    end if;
    
    if p_reason is null then
      raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_reason);
    end if;
    
    allow_changes();
    
    update payment p
       set p.status = c_error
          ,p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_create;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;    
  end fail_payment;
  
  
  --Отмена платежа
  procedure cancel_payment (p_payment_id   payment.payment_id%type
                           ,p_reason       payment.status_change_reason%type)
  is
  begin
    if p_payment_id is null then 
      raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_payment_id);
    end if;
    
    if p_reason is null then
      raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_reason);
    end if;
    
    allow_changes();
       
    update payment p
       set p.status = c_cancel
          ,p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_create;
    
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;       
  end cancel_payment;
  
  
  --Успешный платеж
  procedure successful_finish_payment (p_payment_id payment.payment_id%type)
  is
  begin
    if p_payment_id is null then 
      raise_application_error(common_pack.c_error_code_invalid_unput_parameter,common_pack.c_error_msg_empty_payment_id);
    end if;
    
    allow_changes();
    
    update payment p
       set p.status = c_success
          ,p.status_change_reason = null
     where p.payment_id = p_payment_id
       and p.status = c_create;
    
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;   
  end successful_finish_payment;
  
  
  --Выполняются ли изменения через API
  procedure is_changes_through_api is
  begin
    
    if not g_is_api and not common_pack.is_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_manual_changes,common_pack.c_error_msg_manual_changes);
    end if;
    
  end is_changes_through_api;
  
  --Проверка на возможность удалять платежи
  procedure check_payment_delete_restriction
  is
  begin
    if not common_pack.is_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_delete_forbidden
                             ,common_pack.c_error_msg_delete_forbidden);
    end if;
  end;

end payment_api_pack;
/