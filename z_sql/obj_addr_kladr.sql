select distinct
    o.cad_num,
-- /* АДРЕС v2
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', дом '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', корп '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', стр '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "адрес КЛАДР",
    si.OTHER as "Иное",
    si.note as "адрес ДОК",
    r.letter as "литера",
-- */
-- /* РАЗБИТЫЙ АДРЕС ПО КЛАДР   
        to_char(si.OKATO_CODE) as "Код ОКАТО"
    ,   to_char(si.KLADR_CODE) as "Код КЛАДР"
    ,   to_char(si.POSTAL_CODE) as "Индекс"
    ,   to_char(si.REGION) as "Регион"
    ,   to_char(si.DISTRICT_TYPE) as "Тип Района"
    ,   to_char(si.DISTRICT) as "Район"
    ,   to_char(si.CITY_TYPE) as "Тип МО"
    ,   to_char(si.CITY) as "МО"
    ,   to_char(si.URBAN_DISTRICT) as "Городской район"
    ,   to_char(si.SOVIET_VILLAGE) as "Сельсовет"
    ,   to_char(si.LOCALITY_TYPE) as "Тип НП"
    ,   to_char(si.LOCALITY) as "НП"
    ,   to_char(si.STREET_TYPE) as "Тип ул."
    ,   to_char(si.STREET) as "Улица"
    ,   to_char(si.HOUSE_TYPE) as "Тип дома"
    ,   to_char(si.HOUSE) as "Дом"
    ,   to_char(si.BUILDING_TYPE) as "Тип корпуса"
    ,   to_char(si.BUILDING) as "Корпус"
    ,   to_char(si.STRUCTURE_TYPE) as "Тип строения"
    ,   to_char(si.STRUCTURE) as "Строение"
    ,   to_char(si.APARTMENT_TYPE) as "Тип помещения"
    ,   to_char(si.APARTMENT) as "Помещение"
    ,   to_char(si.OTHER) as "Иное"
    ,   to_char(si.LOCALITY1_TYPE) as "Тип некомм объед гражд"
    ,   to_char(si.LOCALITY1) as "Некомм объед граждан"
-- */
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.site si on(si.parent_id = r.ID AND si.r$table_map_id = 7)
where
     r.id = nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
     and o.cad_num like :S1
