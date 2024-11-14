create or replace package body common_pack is

  g_enable_manual_changes boolean := false; --включен ли флаг возможности внесения ручных изменений

  --Включение разрешения менять данные вручную
  procedure enable_manual_changes is
  begin
    g_enable_manual_changes := true;
  end;
  
  --Отключение разрешения менять данные вручную
  procedure disable_manual_changes is
  begin
    g_enable_manual_changes := false;
  end;
  
  --Разрешены ли ручные изменения на глобальном уровне сессии
  function is_manual_changes_allowed return boolean is
  begin
    return g_enable_manual_changes;
  end;
  
end common_pack;
/