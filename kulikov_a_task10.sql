--�������. ������� 10. ������� �.�.

/*
�����: ������� �.�.
��������: API ��� ��������� "������" � "������ �������"
*/

--�������� �������
declare
  v_message varchar2(100 char) := '������ ������';
  c_create constant payment.status%type := 0;
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1,'internal terminal')
                                                                   ,t_payment_detail(2,'199.5.49.657')
                                                                   ,t_payment_detail(3,'���������� ����� ��������')                                                                  
                                                                   );
begin
  
  if v_payment_detail is not empty then
    
    for i in v_payment_detail.first .. v_payment_detail.last loop
      
      if v_payment_detail(i).field_id is null then
        dbms_output.put_line('ID ���� �� ����� ���� ������');
      end if;
      
      if v_payment_detail(i).field_value is null then
        dbms_output.put_line('�������� � ���� �� ����� ���� ������');
      end if;
      
      dbms_output.put_line('Field_id: ' || v_payment_detail(i).field_id || '. Value: ' || v_payment_detail(i).field_value);
    end loop;
  
  else    
    dbms_output.put_line('��������� �� �������� ������');  
  end if;

  dbms_output.put_line(v_message || '. ������: ' || c_create);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss'));
end;
/

--����� �������
declare
  v_message varchar2(200 char) := '����� ������� � "��������� ������" � ��������� �������';
  c_error constant payment.status%type := 2;
  v_reason payment.status_change_reason%type := '������������ �������';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID ������� �� ����� ���� ������');
  end if;
  
  if v_reason is null then
    dbms_output.put_line('������� �� ����� ���� ������');
  end if;
  
  dbms_output.put_line(v_message || '. ������: ' || c_error || '. �������: ' || v_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy hh24:mi:ss:ff'));
end;
/

--������ �������
declare
  v_message varchar2(200 char) := '������ ������� � ��������� �������';
  c_cancel constant payment.status%type := 3;
  v_reason payment.status_change_reason%type := '������ ������������';
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type := 15;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID ������� �� ����� ���� ������');
  end if;
  
  if v_reason is null then
    dbms_output.put_line('������� �� ����� ���� ������');
  end if;
  
  dbms_output.put_line(v_message || '. ������: '|| c_cancel ||'. �������: ' || v_reason);
  dbms_output.put_line(to_char(v_current_dtime,'dd-mm-yyyy'));
end;
/

--�������� ������
declare
  v_message varchar2(200 char) := '�������� ���������� �������';
  c_success constant payment.status%type := 1;
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;
begin
  if v_payment_id is null then 
    dbms_output.put_line('ID ������� �� ����� ���� ������');
  end if;
  
  dbms_output.put_line(v_message || '. ������: ' || c_success);
  dbms_output.put_line(to_char(v_current_dtime,'dd Month yyyy hh24:mi'));
end;
/

--����������/��������� ������ �� �������
declare
  v_message varchar2(200 char) := '������ ������� ��������� ��� ��������� �� ������ id_����/��������';
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type := 120;
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(2,'199.6.94.888')                                                                
                                                                   );
begin
  
  if v_payment_detail is not empty then
    
    for i in v_payment_detail.first .. v_payment_detail.last loop
      
      if v_payment_detail(i).field_id is null then
        dbms_output.put_line('ID ���� �� ����� ���� ������');
      end if;
      
      if v_payment_detail(i).field_value is null then
        dbms_output.put_line('�������� � ���� �� ����� ���� ������');
      end if;
      
      dbms_output.put_line('Field_id: ' || v_payment_detail(i).field_id || '. Value: ' || v_payment_detail(i).field_value);
    end loop;
  
  else    
    dbms_output.put_line('��������� �� �������� ������');  
  end if;
  
  if v_payment_id is null then 
    dbms_output.put_line('ID ������� �� ����� ���� ������');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'hh24:mi:ss'));
end;
/

--�������� ������ �� ������� �������
declare
  v_message varchar2(200 char) := '������ ������� ������� �� ������ id_�����';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type;
  v_delete_field_ids t_number_array := t_number_array(1, 2);
begin
  
  if v_payment_id is null then 
    dbms_output.put_line('ID ������� �� ����� ���� ������');
  end if;
  
  if v_delete_field_ids is empty then
    dbms_output.put_line('��������� �� �������� ������');
  end if;
  
  dbms_output.put_line(v_message);
  dbms_output.put_line(to_char(v_current_dtime,'"Date: " dd Month yyyy ". Time: " hh24:mi:ss:ff'));
  dbms_output.put_line('���������� ����� ��� ��������: ' || v_delete_field_ids.count());
end;
/
