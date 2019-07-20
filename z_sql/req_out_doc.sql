select distinct
    req.REQUEST_NUMBER as "����� ������",
    decode(req.tax_free, 1, '���������', 0, '������') as "������� ���������",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code like req.state_code) as "������ ������",
    (select z.name from cad_qual_dev.v$_delivery_docs z where z.code = req.delivery_type) as "������ ��������� ���������",
    to_char(req.date_registration, 'YYYY-MM-DD') as "���� �����������",
    to_char(req.date_close, 'YYYY-MM-DD') as "���� ����������",
    rd.global_state,
    rd.doc_num as "����� ���������",
    rd.doc_name as "�������� ���������",
    to_char(rd.doc_date, 'YYYY-MM-DD') as "���� ����������",
    ruc.last_name||' '||ruc.first_name||' '||ruc.middle_name as "��� ������",
    sd.name as "����� ����������",
    rucc.last_name||' '||rucc.first_name||' '||rucc.middle_name as "��� �����������",
    sdc.name as "����� ���������������"
from
    request.request req
    left join request.request_document rd on(rd.request_id = req.id  and rd.global_state = 1
        and(
            substr(rd.doc_subtype_code, 7) in(
               -- '020', -- (����� ����������) -- !!!!!
                '039', -- (������ � ���)
                '043', -- ����������� ������� (�������)
                '023', -- ����������� ������� (��)
                '028', -- ����������� �������
                '034', -- ����������� ������� (���)
                '022', -- ����������� ������� (��)
                '024', -- ����������� ������� (���)
                '017', -- ���
                '026', -- ����������� �� ���������� ��������
              --  '025', -- �������
                '041'  -- ������� � ������������� ���������� ���. ������
              --  '031', -- ��� ����������� ����������� ��������� (�� � ���)
                )
            or
            rd.doc_type_code in(
                '558101170000', -- (������ � ���)
                '558214040000', -- ����������� ������� (�������)
                '558214010000', -- ����������� ������� (��)
                '558218000000', -- ����������� �������
                '558213020000', -- ����������� ������� (���)
                '558213010000', -- ����������� ������� (��)
                '558213030000', -- ����������� ������� (���)
                '558217000000', -- ���
                '558501021400', -- ����������� � ����������� � ��������������
                '558501020100'  -- ����������� �� ���������� ��������
                )
            )
        )
    left join ekon_admin.users ruc on (ruc.id = rd.user_id)
    left join ekon_admin.struct_division sd on(sd.id = ruc.div_id)
    left join request.document_certification dc on(dc.document_id = rd.id)
    left join ekon_admin.users rucc on(rucc.id = dc.user_id)
    left join ekon_admin.struct_division sdc on(sdc.id = rucc.div_id)
where
    req.REQUEST_NUMBER like :S1
    