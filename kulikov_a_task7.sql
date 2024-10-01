--Решение. Задание 7. Куликов А.А.

/*
Автор: Куликов А.А.
Описание: Практическая работа с типом RECORD
*/

declare
  type t_my_example_rec is record(
                                   status_change_reason varchar(200)
                                  ,id number(38,0) not null := 11
                                  ,create_dtime date := sysdate
                                  );
  
  v_first_example_rec t_my_example_rec;
  
  v_second_example_rec t_my_example_rec;
  
  v_third_example_rec t_my_example_rec;
  
begin
  v_first_example_rec.status_change_reason := 'ошибка связи с сервером';
  
  v_second_example_rec.status_change_reason := 'недостаточно средств';
  
  v_third_example_rec.status_change_reason := 'ошибка пользователя';
  
  dbms_output.put_line('v_first_example_rec.status_change_reason : ' || v_first_example_rec.status_change_reason);
  dbms_output.put_line('v_first_example_rec.id : ' || v_first_example_rec.id);
  dbms_output.put_line('v_first_example_rec.create_dtime : ' || to_char(v_first_example_rec.create_dtime,'dd.mm.yyyy hh24:mi:ss'));
  dbms_output.put_line('');
  dbms_output.put_line('v_second_example_rec.status_change_reason : ' || v_second_example_rec.status_change_reason);
  dbms_output.put_line('v_second_example_rec.id : ' || v_second_example_rec.id);
  dbms_output.put_line('v_second_example_rec.create_dtime : ' || to_char(v_second_example_rec.create_dtime,'dd.mm.yyyy hh24:mi:ss'));
  dbms_output.put_line('');
  dbms_output.put_line('v_third_example_rec.status_change_reason : ' || v_third_example_rec.status_change_reason);
  dbms_output.put_line('v_third_example_rec.id : ' || v_third_example_rec.id);
  dbms_output.put_line('v_third_example_rec.create_dtime : ' || to_char(v_third_example_rec.create_dtime,'dd.mm.yyyy hh24:mi:ss'));
  dbms_output.put_line('');
  
  v_second_example_rec := null;
  
  if v_second_example_rec.status_change_reason is null and v_second_example_rec.id is null and v_second_example_rec.create_dtime is null then
    dbms_output.put_line('It’s null');
  else
    dbms_output.put_line('It’s not null');
  end if;

end;
/

declare
  v_payment_detail_field_row payment_detail_field%rowtype;
 
begin
    select *
    into v_payment_detail_field_row
    from payment_detail_field p
   where p.field_id = 4;
   
  dbms_output.put_line('v_payment_detail_field_row.field_id : ' || v_payment_detail_field_row.field_id);
  dbms_output.put_line('v_payment_detail_field_row.name : ' || v_payment_detail_field_row.name);
  dbms_output.put_line('v_payment_detail_field_row.description : ' || v_payment_detail_field_row.description);
end;
/
