select * 
from cohort_users_raw
limit 10;

SELECT * 
FROM cohort_events_raw 
LIMIT 10; 

with cohort_table as (
select 
      user_id,
      full_name,
      email,
      replace(
      replace(
      SPLIT_PART(trim(signup_datetime),' ',1),
     '.','-'),'/','-') as cleaned_date_str
from cohort_users_raw
),
log_table as (
       select *,
       case 
           when cleaned_date_str ~ '^\d{2}-\d{2}-\d{4}$'
           then TO_DATE(cleaned_date_str, 'DD-MM-YYYY')::timestamp
           else null 
           END AS adjusted_signup_datetime
           from cohort_table
)
select *
from log_table;

with event_table as (
select 
      event_id,
      user_id,
      replace(
      replace(
      SPLIT_PART(trim(event_datetime),' ',1),
     '.','-'),'/','-') as event_date_str
from cohort_events_raw
),
ev_table as (
       select *,
       case 
           when event_date_str ~ '^\d{2}-\d{2}-\d{4}$'
           then TO_DATE(event_date_str, 'DD-MM-YYYY')::timestamp
           else null 
           END AS adjusted_event_table
           from event_table
)
select *
from ev_table;

--Чистим даты через REPLACE.
--Я использую SPLIT_PART, чтобы убрать время, так как даты разной длины.
with clean_string as (
    select 
          u.user_id,
          u.signup_datetime,
          u.promo_signup_flag, 
          e.event_id,
          e.event_type,
          e.event_datetime,
          --Использовал Split_part что бы отсечь время
          REPLACE(REPLACE(Split_part(TRIM(u.signup_datetime), ' ', 1), '.','-'),'/','-') as u_str, 
          REPLACE(REPLACE(Split_part(TRIM(e.event_datetime), ' ', 1), '','-'),'/','-') as e_str
from cohort_events_raw e 
join cohort_users_raw u on e.user_id = u.user_id
where e.event_type is not null
  and e.event_type != 'test_event'
),
--Проверяем формат через CASE.Если дата подходит под шаблон (ДД-ММ-ГГГГ), переводим её в формат даты.
converted_data as (
     select *,
     case
     	when u_str ~ '^\d{2}-\d{2}-\d{4}$' then TO_DATE(u_str, 'DD-MM-YYYY')::timestamp
     	else null
     end as signup_dt,
     case
     	when e_str ~ '^\d{2}-\d{2}-\d{4}$' then TO_DATE(e_str, 'DD-MM-YYYY')::timestamp
     	else null
     end as event_dt
     from clean_string
),
--Соединяем всё вместе и считаем разницу в месяцах (стаж).
joined_data as (select
    user_id,
    event_type,
    promo_signup_flag,
    to_char(signup_dt, 'YYYY-MM') as cohort_month,
    to_char(event_dt,'YYYY-MM') as event_month,
--Эту фукцию я взял с гугла
    (extract(year from age(event_dt, signup_dt)) * 12 +
    extract(month from age(event_dt, signup_dt))) as month_offset
    from converted_data
    where signup_dt is not null
    and event_dt is not null
)
--считаем количество уникальных пользователей.
select
      promo_signup_flag,
      cohort_month,
      month_offset,
      count(distinct user_id) as user_total
from joined_data 
where event_month between '2025-01' and '2025-06'
--Групирую через group_by что бы получить итоговые цифры.
group by 1,2,3
order by 1,2,3;
     
       

      
     