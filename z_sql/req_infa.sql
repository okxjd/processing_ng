select distinct
    req.request_number as "����� ������",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "��� ������",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "������ ������",
    req.text as "������ �������",
    to_char(req.date_registration, 'YYYY-MM-DD') as "���� �����������",
    to_char(req.date_close, 'YYYY-MM-DD') as "���� ����������",
    nvl((select rs.name from CAD_QUAL_DEV.V$_REQUEST_SOURCE_TYPE rs where rs.code = req.SOURCE_TYPE),
        (select i.name from CAD_QUAL_DEV.V$_TYPE_INF i where i.code = req.TYPE_INF)) as "�������� ������",
    decode(req.tax_free, 0, '��', 1, '���') as "�������",
    req.payment_code as "��� �������",
    req.payment_complete as "������� ������",
    req.payment_date as "���� ������",
    req.amount/100 as "�����",
    (select q.name from cad_qual_dev.v$_cad_out_doc_type q where q.code = od.doc_subtype) as "����������� ��������",
    (select z.name from cad_qual_dev.v$_delivery_docs z where z.code = req.delivery_type) as "��� � ������ ��������",
    rdoc.doc_num as "���������",
    to_char(rdoc.doc_date, 'YYYY-MM-DD') as "���� ����������",
    rdoc.doc_name as "�������� ����������",
    rUC.LAST_NAME||' '||rUC.FIRST_NAME||' '||rUC.MIDDLE_NAME as "��� ������",
    (select sd.name from ekon_admin.struct_division sd where sd.id = ruc.div_ID) as "����� ����������",
    rUC1.LAST_NAME||' '||rUC1.FIRST_NAME||' '||rUC1.MIDDLE_NAME as "��� �����������",
    (select sd.name from ekon_admin.struct_division sd where sd.id = ruc1.div_ID) as "����� ���������������",
-- /*
    rr.type_dec1 as "��� ���������",
    rr.name as "���������",
-- */
    (select sd.name from ekon_admin.struct_division sd where sd.id = rucz.div_ID) as "��� ������ ������ (�����)",
    rUCz.LAST_NAME||' '||rUCz.FIRST_NAME||' '||rUCz.MIDDLE_NAME as "��� ������ ������ (���������)"
from
    request.request req
    left join ekon_admin.users rucz on(rucz.ID = req.user_id)
    left join request.request_document rdoc on(
        rdoc.request_id = req.id
        and rdoc.global_state = 1
        and substr(rdoc.doc_subtype_code, 7) in('017', '022', '023', '024', '028', '033', '034', '026', '041', '020')
        )
    left join ekon_admin.users ruc on(ruc.ID = rdoc.user_id)
    left join REQUEST.DOCUMENT_CERTIFICATION dc on(dc.document_id = rdoc.id)
    left join ekon_admin.users ruc1 on(ruc1.ID = dc.user_id)
-- /*
    left join (select id, request_id, declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id declarant_id,
        case when declarant_fl_def_id is not null then 'F' when declarant_ul_def_id is not null then 'U' 
        when declarant_gov_def_id is not null then 'O' else null end type_dec from request.request_declarant
        where declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id is not null) ed on(req.id = ed.request_id)
        left join (select id, last_name||' '||first_name||' '||middle_name name, 'F' type_dec1 from zkoks.right_owner_fl
        union select id, name name, 'U' type_dec1 from zkoks.right_owner_ul union select id, name name, 'O' type_dec1
        from zkoks.right_owner_sub) rr on(ed.declarant_id = rr.id and ed.type_dec = rr.type_dec1)
    left join (select 'F' as type_dec, parent_id, address from zkoks.v$_address_string where r$table_map_id = 2 -- ��
        union select 'U' as type_dec, parent_id, address from zkoks.v$_address_string where r$table_map_id = 3 -- ��
        union select 'O' as type_dec, parent_id, address from zkoks.v$_address_string where r$table_map_id = 14 -- ���
        ) si1 on(si1.parent_id = rr.id and si1.type_dec = ed.type_dec)
-- */
    left join request.out_document od on(od.request_id = req.id)
where
    req.request_number like :S1
order by 1
