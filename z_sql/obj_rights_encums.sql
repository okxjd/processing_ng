with abc as (select	to_date('30-01-4019 23:59:59', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct
    o.cad_num as "����������� �����",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "������ ��",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)) as "��� ��",
    '|' as "|", '�����' as "T",
    tr.value as "��� �����",
    ri.name as "������������",
    ri.reg_num as "��������� �����",
    nvl2(ri.numerator, ri.numerator||'/'||ri.denominator, '-') as "����",
    ri.share_descr as "��������� �������� ����",
    to_char(ri.reg_date, 'YYYY-MM-DD') as "���� ����������� �����", to_char(ri.reg_date_end, 'YYYY-MM-DD') as "���� ����������� �����",
    rr.name as "���������������", rr.snils, rr.inn, rr.email, xxx.address as "����� �� ������� �����",
    '' as "������������", '' as "����������"
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.right ri on(ri.reg_id = r.id and ri.reg_date_end is null)
    left join (select id,right_id, '��: '||last_name||' '||first_name||' '||middle_name name, snils, inn, '' as email, 2 as atype from zkoks.right_owner_fl
        union select id,right_id, '���: '||name name, '' as snils, '' as inn, '' as email, 999999 as atype from zkoks.right_owner_sub
        union select id,right_id, '��: '||name name, '' as snils, inn, email, 3 as atype from zkoks.right_owner_ul) rr on(rr.right_id = ri.id)
    left join cad_qual_dev.v$_reg_item tr on(tr.code = ri.type)
    left join zkoks.v$_address_string xxx on(xxx.parent_id = rr.id and xxx.r$table_map_id = rr.atype ) -- �� � ��
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
where
    r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or osn.id is null )
    and ri.id is not null
    and o.cad_num like :S1
union
select distinct
    o.cad_num as "����������� �����",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "������ ��",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)) as "��� ��",
    '|' as "|", '�����������' as "T",
    te.value as "��� �����������",
    e.name as "������������",
    e.reg_num as "��������� �����������",
    '','',
    to_char(e.reg_date, 'YYYY-MM-DD') as "���� ����������� �����", to_char(e.reg_date_end, 'YYYY-MM-DD') as "���� ����������� �����",
    ee.name as "��������������� (�����)", ee.snils, ee.inn, ee.email, yyy.address as "����� �� ������� �����",
    e.duration as "������������", e.encumbrance_content as "����������"
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.encumbrance e on(e.reg_id = r.id and e.reg_date_end is null)
    left join (select id,encumbrance_id, '��: '||last_name||' '||first_name||' '||middle_name name, snils, inn, '' as email, 5 as atype from zkoks.encum_owner_fl
        union select id,encumbrance_id, '���: '||name name, '' as snils, '' as inn, '' as email, 999999 as atype from zkoks.encum_owner_sub
        union select id,encumbrance_id, '��: '||name name, '' as snils, inn, email, 6 as atype from zkoks.encum_owner_ul) ee on(ee.encumbrance_id = e.id)
    left join cad_qual_dev.v$_servitut_type te on(te.code = e.code)
    left join zkoks.v$_address_string yyy on(yyy.parent_id = ee.id and yyy.r$table_map_id = ee.atype ) -- �� � ��
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
where
    r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or osn.id is null )
    and e.id is not null
    and o.cad_num like :S1
order by 1
