with abc as
(select to_date('2018-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as date_start,
        to_date('2018-12-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as date_end1 from dual)

select distinct
    req.request_number as "������",
    to_char(req.date_registration, 'YYYY-MM-DD') as "���� ��� ������",
    to_char(req.date_create, 'YYYY-MM-DD') as "���� �������� ������",
    to_char(req.date_close, 'YYYY-MM-DD') as "���� �������� ������",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as "��� ������",
    (select aa.name from cad_qual_dev.v$_action_ow aa where aa.code like req.action) as "������� ��������",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code like req.state_code) as "������ ������",
    nvl((select rs.name from CAD_QUAL_DEV.V$_REQUEST_SOURCE_TYPE rs where rs.code = req.SOURCE_TYPE),
        (select i.name from CAD_QUAL_DEV.V$_TYPE_INF i where i.code = req.TYPE_INF)) as "�������� ������",
    req.executive as "��� ������ ������",
    ruc2.last_name||' '||ruc2.first_name||' '||ruc2.middle_name as "��� ������ ������",
    (select sd.name from ekon_admin.struct_division sd where sd.id = ruc2.div_ID) as "����� (������)",
    req.number_grp as "������������ �������� ���",
    to_char(decode(req.tax_free, '0','������', '1','���������', 'X')) as "�������",
    (select z.name from cad_qual_dev.v$_delivery_docs z where z.code = req.delivery_type) as "������ ��������� ���������",
    rrrr.delivery_destination as "����� ��������",
    case when exists(select rd.id from request.request_document rd where rd.request_id = req.id
        and substr(rd.doc_subtype_code, 7) like '025' and rd.global_state = 1 and regexp_like(lower(rd.doc_name), '������'))
        then '��' else '���' end as "���� ������������",
    first_value(rd.doc_num)over(partition by rd.REQUEST_ID order by rd.id desc) as "��������� �������",
    first_value(rd.doc_name)over(partition by rd.REQUEST_ID order by rd.id desc) as "������������ �������",
    to_char(first_value(rd.doc_date)over(partition by rd.REQUEST_ID order by rd.id desc), 'YYYY-MM-DD') as "���� �������",
    req.execution_note as "������� �� ���",
    req.text as "������ �������",
    rrrr.rtype as "��� ���������",
    rrrr.pname as "���������",
    rrrr.phone as "�������",
    rrrr.email as "email",
    rrrr.ogrn as "����",
    rra.pname as "�������������",
    agente.agent_post as "��������� �������������",
    agente.email as "��. ����� �������������",
    agente.phone as "���. �������������"
from
    abc a,
    request.request req
    left join request.request_document rd on(rd.request_id = req.ID and substr(rd.doc_subtype_code, 7) like '025' and rd.global_state = 1)
    left join ekon_admin.users ruc2 on(ruc2.id = req.user_id)
    left join (
        select ed.request_id, 'fl' as rtype, fl.last_name||' '||fl.first_name||' '||fl.middle_name as pname,
        ed.phone, ed.email, '' as ogrn, ed.delivery_destination
        from request.request_declarant ed left join zkoks.right_owner_fl fl on(fl.id = ed.declarant_fl_def_id)
        where ed.declarant_fl_def_id is not null
        union
        select ed.request_id, 'ul' as rtype, ul.name as pname, ed.phone as phone, coalesce(ul.email,ed.email) as email, ul.ogrn,
            ed.delivery_destination
        from request.request_declarant ed left join zkoks.right_owner_ul ul on(ul.id = ed.declarant_ul_def_id)
        where ed.declarant_ul_def_id is not null
        union
        select ed.request_id, 'gov' as rtype, sub.name as pname, ed.phone, ed.email, '' as ogrn, ed.delivery_destination
        from request.request_declarant ed left join zkoks.right_owner_sub sub on(sub.id = ed.declarant_gov_def_id)
        where ed.declarant_gov_def_id is not null
        ) rrrr on(rrrr.request_id = req.id)
    left join request.request_declarant agente on(agente.request_id = req.id and agente.agent_id is not null)
    left join (select fl.id, fl.last_name||' '||fl.first_name||' '||fl.middle_name as pname from zkoks.right_owner_fl fl
        ) rra on(rra.id = agente.agent_id)
where
    req.request_number like :S1
order by 1

