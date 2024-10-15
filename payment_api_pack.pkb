create or replace package body payment_api_pack is

  --Создание платежа
  function create_payment(p_from_client_id client.client_id%type
                         ,p_to_client_id client.client_id%type
                         ,p_summa payment.summa%type
                         ,p_currency_id currency.currency_id%type
                         ,p_create_dtime timestamp
                         ,p_payment_detail t_payment_detail_array)
    return payment.payment_id%type
  is
    v_message varchar2(100 char) := 'Платеж создан';
    v_payment_id payment.payment_id%type;                                                                 
    
  begin
    
    if p_payment_detail is not empty then
      
      for i in p_payment_detail.first .. p_payment_detail.last loop
        
        if p_payment_detail(i).field_id is null then
          dbms_output.put_line(c_error_msg_empty_field_id);
        end if;
        
        if p_payment_detail(i).field_value is null then
          dbms_output.put_line(c_error_msg_empty_field_value);
        end if;
        
        dbms_output.put_line('Field_id: ' || p_payment_detail(i).field_id || '. Value: ' || p_payment_detail(i).field_value);
      end loop;
    
    else    
      dbms_output.put_line(c_error_msg_empty_collection);  
    end if;
  
    dbms_output.put_line(v_message || '. Статус: ' || c_create);
    dbms_output.put_line(to_char(p_create_dtime,'dd.mm.yyyy hh24:mi:ss'));
    
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
    
    dbms_output.put_line('Payment_id of new payment: ' || v_payment_id);
    
    insert into payment_detail(payment_id
                              ,field_id
                              ,field_value)
    select v_payment_id
          ,value(t).field_id
          ,value(t).field_value
      from table(p_payment_detail) t;
    
    return v_payment_id;
  end;
  
  
  --Сброс платежа
  procedure fail_payment (p_payment_id payment.payment_id%type
                         ,p_reason payment.status_change_reason%type)
  is
    v_message varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины';
    v_current_dtime timestamp := systimestamp;
    
  begin
    if p_payment_id is null then 
      dbms_output.put_line(c_error_msg_empty_payment_id);
    end if;
    
    if p_reason is null then
      dbms_output.put_line(c_error_msg_empty_reason);
    end if;
    
    dbms_output.put_line(v_message || '. Статус: ' || c_error || '. Причина: ' || p_reason);
    dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss:ff'));
    
    update payment p
       set p.status = c_error
          ,p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_create;
     
  end;
  
  
  --Отмена платежа
  procedure cancel_payment (p_payment_id payment.payment_id%type
                           ,p_reason payment.status_change_reason%type)
  is
    v_message varchar2(200 char) := 'Отмена платежа с указанием причины';
    v_current_dtime timestamp := systimestamp;
  begin
    if p_payment_id is null then 
      dbms_output.put_line(c_error_msg_empty_payment_id);
    end if;
    
    if p_reason is null then
      dbms_output.put_line(c_error_msg_empty_reason);
    end if;
    
    dbms_output.put_line(v_message || '. Статус: '|| c_cancel ||'. Причина: ' || p_reason);
    dbms_output.put_line(to_char(v_current_dtime,'dd-mm-yyyy'));
    
    update payment p
       set p.status = c_cancel
          ,p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_create;
       
  end;
  
  
  --Успешный платеж
  procedure successful_finish_payment (p_payment_id payment.payment_id%type)
  is
    v_message varchar2(200 char) := 'Успешное завершение платежа';
    v_current_dtime timestamp := systimestamp;
  begin
    if p_payment_id is null then 
      dbms_output.put_line(c_error_msg_empty_payment_id);
    end if;
    
    dbms_output.put_line(v_message || '. Статус: ' || c_success);
    dbms_output.put_line(to_char(v_current_dtime,'dd Month yyyy hh24:mi'));
    
    update payment p
       set p.status = c_success
          ,p.status_change_reason = null
     where p.payment_id = p_payment_id
       and p.status = c_create;
       
  end;

end;
