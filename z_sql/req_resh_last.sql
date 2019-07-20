with rrrrrrr as
(select distinct
    req.request_number as uch_delo,
    s_type2.name as uch_state,
    inf.name as istochnik,
    req.date_registration as uch_date_registration,
  --  req.date_create as uch_date_create,
    req.date_close as uch_date_close,
    d_type2.name as tip_uch,
    req.number_grp as grp,
    req.text as uch_text,
    req.id as re_id,
    first_value(ruc.div_ID)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as division_id,
    first_value(rUC.LAST_NAME||' '||rUC.FIRST_NAME||' '||rUC.MIDDLE_NAME)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as fio_cert,
    first_value(ruc1.div_ID)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as division_id1,
    first_value(rUC1.LAST_NAME||' '||rUC1.FIRST_NAME||' '||rUC1.MIDDLE_NAME)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as fio_cert1,
    first_value(rd.id)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_id,
    first_value(rd.doc_num)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc,
    first_value(rd.doc_name)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_name,
    first_value(rd.doc_date)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_date
    , first_value(regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-10 ),
        dbms_lob.instr(rd.xml, '<Decision>', 180, 1)+10 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})',''))over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_txt,
    first_value(regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-8 ),
        dbms_lob.instr(rd.xml, '<Errors>', 180, 1)+8 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})',''))over(partition by rd.REQUEST_ID order by rd.doc_date desc) as error_txt
from
    request.request req
    left join REQUEST.REQUEST_DOCUMENT rd on (rd.REQUEST_ID = req.ID and substr(rd.doc_subtype_code, 7) like '025')
    left join CAD_QUAL_DEV.V$_TYPE_INF inf on(inf.code = req.TYPE_INF)
    left join cad_qual_dev.v$_request_type2 d_type2 on (req.request_type_id = d_type2.code)
    left join cad_qual_dev.v$_request_state2 s_type2 on (req.state_code = s_type2.code)
    left join ekon_admin.users ruc on (ruc.ID = rd.user_id)
    left join REQUEST.DOCUMENT_CERTIFICATION dc on(dc.document_id = rd.id)
    left join ekon_admin.users ruc1 on (ruc1.ID = dc.user_id)
where
    rd.global_state = 1
    and req.request_number like :S1
)
select distinct
    q.uch_delo as "заявка",
    q.uch_state,
    q.istochnik,
    to_char(q.uch_date_registration, 'YYYY-MM-DD') as "дата регистрации",
    to_char(q.uch_date_close, 'YYYY-MM-DD') as "дата завершения",
    q.tip_uch as "тип заявки",
    q.grp as "одновременная ГРП",
    q.uch_text as "особые отметки",
    q.doc "номер решения",
    to_char(q.doc_date, 'YYYY-MM-DD') as "дата принятия решения",
    q.doc_name as "наименование решения",
    q.fio_cert as "ФИО создавшего решение",
    (select sd.name from ekon_admin.struct_division sd where sd.id = q.division_id) as division,
    q.fio_cert1 as "ФИО удостоверившего решение",
    (select sd.name from ekon_admin.struct_division sd where sd.id = q.division_id1) as division_cert,
    q.doc_txt as "текст решения",
    q.error_txt as "текст заключения",
    nvl(
        regexp_substr(q.error_txt, '(основании|соответствии[ со]{0,4}|согласно|предусмотренные){0,1}([ \.,]*[и]?[ ]*(п[\. п]{0,3}|пункт[ао]{0,1}[михв]{0,3}|ч|част[ьиюям]{1,3}|ст|стать[ияейё]{1,2})([ \.,]*[и]?[ ]*\d{1,2})+)+'),
        regexp_substr(q.doc_txt, '(основании|соответствии[ со]{0,4}|согласно|предусмотренные){0,1}([ \.,]*[и]?[ ]*(п[\. п]{0,3}|пункт[ао]{0,1}[михв]{0,3}|ч|част[ьиюям]{1,3}|ст|стать[ияейё]{1,2})([ \.,]*[и]?[ ]*\d{1,2})+)+')) as decision2,
    case when
        (select min(rrd.id) from REQUEST.REQUEST_DOCUMENT rrd where rrd.REQUEST_ID = q.re_id and substr(rrd.doc_subtype_code, 7) like '025'
        and rrd.doc_num is not null and rrd.global_state = 1) not like q.doc_id then 'да' else 'нет' end as "есть еще решения по заявке"
from
    rrrrrrr q
order by q.uch_delo
