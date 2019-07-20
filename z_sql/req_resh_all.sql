select distinct
    req.request_number as "������",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "������ ������",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "��� ������",
    nvl((select rs.name from CAD_QUAL_DEV.V$_REQUEST_SOURCE_TYPE rs where rs.code = req.SOURCE_TYPE),
        (select i.name from CAD_QUAL_DEV.V$_TYPE_INF i where i.code = req.TYPE_INF)) as "�������� ������",
    to_char(req.date_registration, 'YYYY-MM-DD') as "���� �����������",
    to_char(req.date_close, 'YYYY-MM-DD') as "���� ����������",
    req.text as "������ �������",
    rd.id as "id ���",
    decode(rd.global_state, 0,'����', 1,'�����', 2,'�����', to_char(rd.global_state)) as rd_state,
    rd.doc_num as "����� �������",
    to_char(rd.doc_date, 'YYYY-MM-DD') as "���� �������� �������",
    rd.doc_name as "������������ �������",
    rUC.LAST_NAME||' '||rUC.FIRST_NAME||' '||rUC.MIDDLE_NAME as "��� ���������� �������",
    (select sd.name from ekon_admin.struct_division sd where sd.id = ruc.div_ID) as division,
    rUC1.LAST_NAME||' '||rUC1.FIRST_NAME||' '||rUC1.MIDDLE_NAME as "��� ��������������� �������",
    (select sd.name from ekon_admin.struct_division sd where sd.id = ruc1.div_ID) as division_cert,
    regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-10 ),
        dbms_lob.instr(rd.xml, '<Decision>', 180, 1)+10 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})','') as "����� �������",
    regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-8 ),
        dbms_lob.instr(rd.xml, '<Errors>', 180, 1)+8 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})','') as "����� ����������",
    nvl(
        regexp_substr(regexp_replace(replace(replace(replace(
            dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-3998),
            0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-8 ),
            dbms_lob.instr(rd.xml, '<Errors>', 180, 1)+8 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})',''),
            '(���������|������������[ ��]{0,4}|��������|���������������){0,1}([ \.,]*[�]?[ ]*(�[\. �]{0,3}|�����[��]{0,1}[����]{0,3}|�|����[�����]{1,3}|��|�����[����]{1,2})([ \.,]*[�]?[ ]*\d{1,2})+)+'),
        regexp_substr(regexp_replace(replace(replace(replace(
            dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-3998),
            0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-10 ),
            dbms_lob.instr(rd.xml, '<Decision>', 180, 1)+10 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})',''),
            '(���������|������������[ ��]{0,4}|��������|���������������){0,1}([ \.,]*[�]?[ ]*(�[\. �]{0,3}|�����[��]{0,1}[����]{0,3}|�|����[�����]{1,3}|��|�����[����]{1,2})([ \.,]*[�]?[ ]*\d{1,2})+)+')
        ) as decision2
from
    request.request req
    left join REQUEST.REQUEST_DOCUMENT rd on(rd.REQUEST_ID = req.ID and substr(rd.doc_subtype_code, 7) like '025')
    left join ekon_admin.users ruc on(ruc.ID = rd.user_id)
    left join REQUEST.DOCUMENT_CERTIFICATION dc on(dc.document_id = rd.id)
    left join ekon_admin.users ruc1 on(ruc1.ID = dc.user_id)
where
   -- rd.global_state = 1 and
    req.request_number like :S1
   -- and rd.doc_date between to_date('01.01.2018 00:00:00', 'DD.MM.YYYY HH24:MI:SS') and to_date('31.03.2018 23:59:59', 'DD.MM.YYYY HH24:MI:SS')
order by req.request_number, rd.id asc
