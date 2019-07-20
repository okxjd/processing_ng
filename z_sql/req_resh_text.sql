with rrrrrrr as
(select distinct
    rd.doc_num as doc,
    rd.doc_name as doc_name,
    rd.doc_date as doc_date,
    ruc.div_ID as division_id,
    rUC.LAST_NAME||' '||rUC.FIRST_NAME||' '||rUC.MIDDLE_NAME as fio_cert,
    ruc1.div_ID as division_id1,
    rUC1.LAST_NAME||' '||rUC1.FIRST_NAME||' '||rUC1.MIDDLE_NAME as fio_cert1,
    regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-10 ),
        dbms_lob.instr(rd.xml, '<Decision>', 180, 1)+10 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})','') as doc_txt,
    regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-8 ),
        dbms_lob.instr(rd.xml, '<Errors>', 180, 1)+8 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})','') as error_txt
from
    request.request req
    left join REQUEST.REQUEST_DOCUMENT rd on(rd.REQUEST_ID = req.ID and substr(rd.doc_subtype_code, 7) like '025')
    left join ekon_admin.users ruc on(ruc.ID = rd.user_id)
    left join REQUEST.DOCUMENT_CERTIFICATION dc on(dc.document_id = rd.id)
    left join ekon_admin.users ruc1 on(ruc1.ID = dc.user_id)
where
    rd.doc_num like :S1
)
select distinct
    q.doc "номер решени€",
    to_char(q.doc_date, 'DD.MM.YYYY') as "дата прин€ти€ решени€",
    q.doc_name as "наименование решени€",
    q.fio_cert as "‘»ќ создавшего решение",
    (select sd.name from ekon_admin.struct_division sd where sd.id = q.division_id) as division,
    q.fio_cert1 as "‘»ќ удостоверившего решение",
    (select sd.name from ekon_admin.struct_division sd where sd.id = q.division_id1) as division_cert,
    q.doc_txt as "текст решени€",
    q.error_txt as "текст заключени€",
    nvl(
        regexp_substr(q.error_txt, '(основании|соответствии[ со]{0,4}|согласно|предусмотренные){0,1}([ \.,]*[и]?[ ]*(п[\. п]{0,3}|пункт[ао]{0,1}[михв]{0,3}|ч|част[ьию€м]{1,3}|ст|стать[и€ейЄ]{1,2})([ \.,]*[и]?[ ]*\d{1,2})+)+'),
        regexp_substr(q.doc_txt, '(основании|соответствии[ со]{0,4}|согласно|предусмотренные){0,1}([ \.,]*[и]?[ ]*(п[\. п]{0,3}|пункт[ао]{0,1}[михв]{0,3}|ч|част[ьию€м]{1,3}|ст|стать[и€ейЄ]{1,2})([ \.,]*[и]?[ ]*\d{1,2})+)+')) as decision2
from
    rrrrrrr q
order by q.doc