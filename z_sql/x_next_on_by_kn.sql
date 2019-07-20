with abc as (select
	:S1 as k_num, to_date('16-01-3019 00:00:00', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct /*+ LEADING(ooo, o) */
    ooo.cad_num as "��",
    to_char(roo.date_registered, 'YYYY-MM-DD') as "���� ����������",
    to_char(roo.date_canceled, 'YYYY-MM-DD') as "���� ������",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osnoo.status_type, ooo.status)) as "������ ��",
    nvl(nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = roo.type),
            (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = roo.type)),
            (select ok.kind from zkoks.obj_kind ok where ok.id = ooo.obj_kind_id)) as "��� ��",
    case when exists(select ri.id from zkoks.right ri where ri.reg_id = roo.id and ri.reg_date_end is null) then '��' else '���' end as "�����",
    case when exists(select e.id from zkoks.encumbrance e where e.reg_id = roo.id and e.reg_date_end is null) then '��' else '���' end as "�����������",
    
    o.cad_num as "�����������",
    to_char(r.date_registered, 'YYYY-MM-DD') as "���� ����������",
    to_char(r.date_canceled, 'YYYY-MM-DD') as "���� ������",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "������ ��",
    nvl(nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
            (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)),
            (select ok.kind from zkoks.obj_kind ok where ok.id = o.obj_kind_id)) as "��� ��",
    (select cm.name from CAD_QUAL_DEV.V$_PARCEL_CREATE_METHOD cm where cm.code = r.method) as method,
    case when o.obj_kind_id = 22 and r.assignation_code is null then r.assignation_name
		when o.obj_kind_id = 22 and r.assignation_code is not null then (select name from cad_qual_dev.v$_building_purpose where code = r.assignation_code)
		when o.obj_kind_id = 23 then (select name from cad_qual_dev.v$_flat_purpose where code = r.assignation_code) end as "���������� ���",
    replace(replace(dbms_lob.substr(r.name, 4000, 1), chr(10) , ' '), chr(13), '') as "������������",
    replace(replace(dbms_lob.substr(r.note_long, 4000, 1), chr(10) , ' '), chr(13), '') as "����������",
    p.value as "���������", u.doc as "�� �� ���", reso.value as "�� �� �����", reso540.name as "�� �� 540 ��.", u.fact as "������. ���.", '|' as "||",
    replace(to_char(decode(o.obj_kind_id, 22,ch.area, 23,ch.area, coalesce(a009.value, a008.value, a002.value)), 'fm9999999999999999990D00'), ',', '.') as "�������",
    decode(coalesce(a009.code, a008.code, a002.code), '009', '�����', '008', '������', '002', '�����') as "��� �������",
    to_char(WMSYS.WM_CONCAT(nvl2(kpp.param_type, kpp.param_type||'='||kpp.param_val||'; ', '-'))over(partition by o.id)) as "��� ����� ����",
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', ��� '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', ���� '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', ��� '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "����� �����",
    case when exists(select ri.id from zkoks.right ri where ri.reg_id = r.id and ri.reg_date_end is null) then '��' else '���' end as "�����",
    case when exists(select e.id from zkoks.encumbrance e where e.reg_id = r.id and e.reg_date_end is null) then '��' else '���' end as "�����������",
    vhd.osnovanie_ucheta as "�������� �����",
    vhd.osnovanie_ucheta_req as "������������ ��������� �����",
    vhd.ki_name as "����������� 1-�� �����",
    vhd.ki_att as "�������� �����������",
    vhd.ki_org as "����������� �����������",
    to_char(vhd.date_contractor, 'YYYY-MM-DD') as "���� �����"
FROM abc a,

    zkoks.obj ooo
    left join zkoks.reg roo on(roo.obj_id = ooo.id)
    left join zkoks.obj_status_new osnoo on(osnoo.obj_id = ooo.id)
    
    left join zkoks.cad_number_prev cp on(cp.cad_num = ooo.cad_num)
    left join zkoks.reg r on(r.id = cp.reg_id)
    left join zkoks.obj o on(o.id = r.obj_id)

    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
    left join zkoks.category c on(c.reg_id = r.id)
    left join cad_qual_dev.v$_purpose_land p on(p.code = c.code)
    left join zkoks.utilization u on(u.reg_id = r.id)
    left join cad_qual_dev.v$_resolved_use reso on(reso.code = u.code)
    left join cad_qual_dev.v$_resolved_use_type_540 reso540 on(reso540.code = u.code540)
    left join zkoks.area_new a009 on(a009.reg_id = r.id and a009.code = '009')
    left join zkoks.area_new a008 on(a008.reg_id = r.id and a008.code = '008'
        and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id = r.id and a8.code = '009'))
    left join zkoks.area_new a002 on(a002.reg_id = r.id and a002.code = '002')
    left join zkoks.characteristic ch on(ch.reg_id = r.id)
    left join zkoks.site si on(si.parent_id = r.ID AND si.r$table_map_id = 7)
    left join (select kp.reg_id, decode(kp.type, '01', '�����', '02', '�������', '03', '�����', '04', '������',
        '05', '�������', '06', '������� ���������', null) as param_type, kp.value as param_val
        from zkoks.key_parametrs kp) kpp on(kpp.reg_id = r.id and r.type in('002002004000','002002004002'))
        
    left join (select distinct ovh.id as o_id, case when (req.id is null and ed.file_name is null) then Null when req.id is not Null then req.REQUEST_NUMBER
        else ed.file_name end as osnovanie_ucheta, req.date_registration as date_registration, req.date_close as date_close,
        r1.date_egroks as date_egroks, (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as osnovanie_ucheta_req
        , c.last_name||' '||c.first_name||' '||c.middle_name as ki_name, c.certificate as ki_att, c.name_org as ki_org, r1.date_contractor
        from zkoks.obj ovh left join zkoks.reg r1 on(r1.obj_id = ovh.id) left join request.request req on(req.id = r1.request_id) left join zkoks.EDOC_INFO ed on(r1.EDOC_INFO_ID = ed.id)
        left join zkoks.contractor c on(c.id = r1.contractor_id) where r1.id = (select min(id) from zkoks.reg where obj_id = ovh.id)
        ) vhd on(vhd.o_id = o.id)

where
    roo.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = ooo.id and rr.date_egroks <= aa.date_report)
    and( (osnoo.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=ooo.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report))  )
        or osnoo.id is null  )
        
    and(
        (r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
        and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
            and(ss.status_change_date is null or ss.status_change_date >= ab.date_report))  )
            or osn.id is null  )
        )
        or r.id is null
        )
    
    and ooo.cad_num like a.k_num

order by 1, 3
