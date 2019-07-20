select distinct
    o.cad_num,
-- /* ����� v2
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', ��� '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', ���� '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', ��� '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "����� �����",
    si.OTHER as "����",
    si.note as "����� ���",
    r.letter as "������",
-- */
-- /* �������� ����� �� �����   
        to_char(si.OKATO_CODE) as "��� �����"
    ,   to_char(si.KLADR_CODE) as "��� �����"
    ,   to_char(si.POSTAL_CODE) as "������"
    ,   to_char(si.REGION) as "������"
    ,   to_char(si.DISTRICT_TYPE) as "��� ������"
    ,   to_char(si.DISTRICT) as "�����"
    ,   to_char(si.CITY_TYPE) as "��� ��"
    ,   to_char(si.CITY) as "��"
    ,   to_char(si.URBAN_DISTRICT) as "��������� �����"
    ,   to_char(si.SOVIET_VILLAGE) as "���������"
    ,   to_char(si.LOCALITY_TYPE) as "��� ��"
    ,   to_char(si.LOCALITY) as "��"
    ,   to_char(si.STREET_TYPE) as "��� ��."
    ,   to_char(si.STREET) as "�����"
    ,   to_char(si.HOUSE_TYPE) as "��� ����"
    ,   to_char(si.HOUSE) as "���"
    ,   to_char(si.BUILDING_TYPE) as "��� �������"
    ,   to_char(si.BUILDING) as "������"
    ,   to_char(si.STRUCTURE_TYPE) as "��� ��������"
    ,   to_char(si.STRUCTURE) as "��������"
    ,   to_char(si.APARTMENT_TYPE) as "��� ���������"
    ,   to_char(si.APARTMENT) as "���������"
    ,   to_char(si.OTHER) as "����"
    ,   to_char(si.LOCALITY1_TYPE) as "��� ������ ����� �����"
    ,   to_char(si.LOCALITY1) as "������ ����� �������"
-- */
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.site si on(si.parent_id = r.ID AND si.r$table_map_id = 7)
where
     r.id = nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
     and o.cad_num like :S1
