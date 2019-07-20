select distinct
    req.request_number as "номер заявки",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "тип заявки",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "статус заявки",
    nvl((select rs.name from CAD_QUAL_DEV.V$_REQUEST_SOURCE_TYPE rs where rs.code = req.SOURCE_TYPE),
        (select i.name from CAD_QUAL_DEV.V$_TYPE_INF i where i.code = req.TYPE_INF)) as "источник заявки",
    (select z.name from cad_qual_dev.v$_delivery_docs z where z.code = req.delivery_type) as "способ получения исходящих",
    to_char(req.date_registration, 'YYYY-MM-DD') as "дата регистрации",
    to_char(req.date_create, 'YYYY-MM-DD') as "дата прихода в АИС",
    to_char(req.date_close, 'YYYY-MM-DD') as "дата завершения",
    req.number_grp as "одновременная ГРП",
    req.executive as "кто принял заявку",
    req.text as "особые отметки",
    req.execution_note as "отметка об исп"
    -- ,
    -- ed.type_dec as "тип заявителя",
    -- rr.name as "заявитель"
from
    request.request req
    -- left join (
        -- select id, request_id, declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id as declarant_id,
        -- case when declarant_fl_def_id is not null then 'ФИЗ' when declarant_ul_def_id is not null then 'ЮР'
        -- when declarant_gov_def_id is not null then 'ОГВ' else null end type_dec
        -- from request.request_declarant where declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id is not null
        -- ) ed on(ed.request_id = req.id)
    -- left join (
        -- select id, last_name||' '||first_name||' '||middle_name name, right_id, '' as  ogrn, '' as email, 'ФИЗ' type_dec1 from zkoks.right_owner_fl
        -- union select id, name name, right_id, ogrn as  ogrn, email as email, 'ЮР' type_dec1 from zkoks.right_owner_ul
        -- union select id, name name, right_id, '' as  ogrn, '' as email, 'ОГВ' type_dec1 from zkoks.right_owner_sub)
        -- rr on(ed.declarant_id = rr.id and rr.type_dec1 = ed.type_dec)
where
    req.request_number like :S1
order by 1
