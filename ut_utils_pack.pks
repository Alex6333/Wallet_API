create or replace package ut_utils_pack is

  -- Author  : Куликов А.А.
  -- Purpose : Движок для реализации Unit-тестов
  
  -- Запуск тестов
  procedure run_tests(p_package_name user_objects.object_name%type := null);

end ut_utils_pack;
/