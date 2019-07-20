select distinct
'|' as "|",
    rrr.request_number as "учетное дело",

    r.request_number as "доп",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code like r.state_code) as "Статус",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like r.request_type_id) as "Тип",
    to_char(r.date_registration, 'YYYY-MM-DD') as "дата рег допа",
    case when exists(select rdd.id from request.request_declarant_document rdd left join request.request_document_img rdi1 on(rdi1.request_doc_id = rdd.id)
        where r.id = rdd.request_id and( rdd.doc_type_id in('558211010000','558203000000','558219000000')
        or regexp_like(lower(rdi1.file_name), '^(guoks|gkuoks|gkuzu|act).*')
        )) then 'есть' else 'нет' end as "ТП МП Акт"
from
    request.reg_folder rf 
    left join request.request r on(rf.id = r.REG_FOLDER_ID and r.request_type_id in('022002', '022003'))
    left join request.request rrr on(rrr.request_number = rf.request_number)
where
    rrr.request_number like :S1
  --  r.request_number like :S1
    and r.request_number is not null
order by rrr.request_number
