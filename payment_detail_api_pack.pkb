create or replace package body payment_detail_api_pack is

  --Добавление/изменение данных по платежу
  procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type
                                                              ,p_payment_detail t_payment_detail_array)
  is
    v_message varchar2(200 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
    v_current_dtime timestamp := systimestamp;
  begin
    
    if p_payment_id is null then 
      dbms_output.put_line(payment_api_pack.c_error_msg_empty_payment_id);
    end if; 
     
    if p_payment_detail is not empty then
      
      for i in p_payment_detail.first .. p_payment_detail.last loop
        
        if p_payment_detail(i).field_id is null then
          dbms_output.put_line(payment_api_pack.c_error_msg_empty_field_id);
        end if;
        
        if p_payment_detail(i).field_value is null then
          dbms_output.put_line(payment_api_pack.c_error_msg_empty_field_value);
        end if;
        
        dbms_output.put_line('Field_id: ' || p_payment_detail(i).field_id || '. Value: ' || p_payment_detail(i).field_value);
      end loop;
    
    else    
      dbms_output.put_line(payment_api_pack.c_error_msg_empty_collection);  
    end if;
    
    dbms_output.put_line(v_message);
    dbms_output.put_line(to_char(v_current_dtime,'hh24:mi:ss'));
    
    merge into payment_detail pd
    using (select p_payment_id payment_id
                 ,value(t).field_id field_id
                 ,value(t).field_value field_value
             from table(p_payment_detail) t) n
       on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
    when matched then
      update set pd.field_value = n.field_value
    when not matched then
      insert (payment_id
             ,field_id
             ,field_value
             )
      values (n.payment_id
             ,n.field_id
             ,n.field_value
             );
    
  end;
  
  --Удаление данных по деталям платежа
  procedure delete_payment_detail (p_payment_id payment.payment_id%type
                                                    ,p_delete_field_ids t_number_array)
  is
    v_message varchar2(200 char) := 'Детали платежа удалены по списку id_полей';
    v_current_dtime timestamp := systimestamp;
  begin
    
    if p_payment_id is null then 
      dbms_output.put_line(payment_api_pack.c_error_msg_empty_payment_id);
    end if;
    
    if p_delete_field_ids is null or p_delete_field_ids is empty then
      dbms_output.put_line(payment_api_pack.c_error_msg_empty_collection);
    end if;
    
    dbms_output.put_line(v_message);
    dbms_output.put_line(to_char(v_current_dtime,'"Date: " dd Month yyyy ". Time: " hh24:mi:ss:ff'));
    dbms_output.put_line('Количество полей для удаления: ' || p_delete_field_ids.count());
    
    delete payment_detail pd
     where pd.payment_id = p_payment_id
       and pd.field_id in (select value(t) from table(p_delete_field_ids) t);
    
  end;

end payment_detail_api_pack;
/