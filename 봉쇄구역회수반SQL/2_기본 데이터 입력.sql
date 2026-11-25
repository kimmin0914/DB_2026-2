-- 봉쇄구역 회수반 / 5단계 Oracle SQL 구현
-- 설계의 시연 사건 입력: 구역 6 / 조사 12 / 퍼즐 3 / 증거 2 / 결말 2
-- Oracle Database 21c XE / UTF-8 / 실행 계정: C##DBSOFT
SET DEFINE OFF
SET SERVEROUTPUT ON
SET AUTOCOMMIT OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM CASE_FILE WHERE case_id=1;
    IF v_count <> 0 THEN RAISE_APPLICATION_ERROR(-20004, '시연 사건 1이 이미 있습니다. 중복 입력하지 않습니다.'); END IF;
END;
/

INSERT INTO CASE_FILE (case_id, title, briefing)
VALUES (1, '봉쇄구역 회수반: 닫힌 문을 연 기록', '봉쇄가 풀리기 전 보안실의 CCTV를 회수하라. 조작된 대피 기록과 봉쇄 명령을 조사하고 증거의 원본·복사본과 탈출 경로를 선택한다.');

INSERT INTO AREA (case_id, area_no, area_name, area_type, map_x, map_y)
VALUES (1, 1, '옥상 진입점', 'START', 0, 0);

INSERT INTO AREA (case_id, area_no, area_name, area_type, map_x, map_y)
VALUES (1, 2, '옥상 탈출점', 'EXIT', 0, 1);

INSERT INTO AREA (case_id, area_no, area_name, area_type, map_x, map_y)
VALUES (1, 3, '중앙 복도', 'NORMAL', 1, 0);

INSERT INTO AREA (case_id, area_no, area_name, area_type, map_x, map_y)
VALUES (1, 4, '보안실', 'NORMAL', 2, 0);

INSERT INTO AREA (case_id, area_no, area_name, area_type, map_x, map_y)
VALUES (1, 5, '발전 제어실', 'NORMAL', 1, 1);

INSERT INTO AREA (case_id, area_no, area_name, area_type, map_x, map_y)
VALUES (1, 6, '하역장', 'EXIT', 2, 1);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 1, 1, 'DIALOGUE', '회수 지시', '무전 담당자: 봉쇄가 풀리기 전에 보안실의 CCTV 기록을 가져와.' || CHR(10) || '주인공: 대피 인원은 전부 빠져나간 겁니까?' || CHR(10) || '무전 담당자: 명단에는 그렇게 되어 있어. 복사본만 확보하고 돌아와.', 1);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 2, 3, 'CLUE', '뒤섞인 상황판', '봉쇄 표시 21:17 / 이상 징후 21:10 / 경보 발생 21:12. 발생 순서는 이상 징후, 경보, 봉쇄이다.', 1);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 3, 4, 'CLUE', '보안 잠금 메모', '잠금 번호는 이상 징후, 경보, 봉쇄 순서로 각 표시 시각의 분 일의 자리를 이어 붙인 세 자리이다. 앞의 0도 입력한다.', 1);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 4, 4, 'STORY', '대피되지 않은 이름', '인원 명단의 마지막 세 이름이 지워져 있다. 펜 자국 아래에는 대피 완료가 아니라 출구 폐쇄라는 문장이 남아 있다.', 2);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 5, 4, 'CLUE', 'CCTV 시계 점검표', '이 카메라의 시계는 실제 시각보다 2분 빠르다. 문제의 문이 닫힌 장면에 표시된 시각은 21:17이다.', 3);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 6, 4, 'CLUE', '출입 명령 목록', '21:12 A13 경보 발령 / 21:13 D07 출입 차단 / 21:15 B42 출입 차단 / 21:16 C09 봉쇄 승인 / 21:17 E26 출입 차단. 여러 차단 명령 중 CCTV 장면의 실제 시각과 일치하는 코드를 찾는다.', 4);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 7, 5, 'CLUE', '비상 전력 기준', '남은 전력 한도는 6이다. 안전한 탈출에는 화물 승강기와 복도 조명이 필요하다. 실험실 배기는 탈출에 필요하지 않다.', 1);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 8, 5, 'CLUE', '세 회로의 부하', '입력 자리 순서는 승강기 4, 조명 2, 배기 3이다. 켜짐은 1, 꺼짐은 0으로 입력한다. 장갑 두 손을 비워야 패널을 조작할 수 있다.', 2);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 9, 5, 'DIALOGUE', '남겨진 음성', '작업자 녹음: 승인도 떨어지기 전에 문부터 잠갔어. 밖에서는 대피가 끝났다고 할 거야.' || CHR(10) || '주인공: 사고 순서가 보고서와 맞지 않는다.', 3);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 10, 3, 'STORY', '원본 보존 주의', 'CCTV 복사 기능은 화면만 추출한다. 시계 보정 이력과 원본 서명은 원본 장치에 남는다. 원본 장치는 두 손으로 들어야 하며 사다리를 오를 수 없다.', 2);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 11, 2, 'DIALOGUE', '옥상에서 온 독촉', '무전 담당자: 사다리로 돌아와. 화면만 있어도 보고서는 쓸 수 있어.' || CHR(10) || '주인공: 원본 서명이 없으면 봉쇄 시각을 입증할 수 없습니다.' || CHR(10) || '무전 담당자: 선택은 네가 해.', 1);

INSERT INTO INSPECTION (case_id, inspection_no, area_no, inspection_type, title, content, display_order)
VALUES (1, 12, 6, 'DIALOGUE', '하역장 마지막 통신', '무전 담당자: 전원이 돌아왔군. 무엇을 가져왔지?' || CHR(10) || '주인공: 그날 닫힌 문이 사고였는지 명령이었는지 확인할 기록입니다.', 1);

INSERT INTO PUZZLE (case_id, puzzle_no, area_no, puzzle_name, puzzle_type, prompt, answer_key, hint_text, solved_text, prerequisite_puzzle_no, required_free_hands)
VALUES (1, 1, 4, '뒤섞인 기록', 'CODE', '발생 순서에 따라 분의 일의 자리 세 자리를 입력한다.', '027', '발생 순서로 21:10, 21:12, 21:17을 나열한다.', '보안 기록함이 열린다. CCTV 원본은 두 손을 사용하고 복사본은 화면만 담는다.', NULL, 0);

INSERT INTO PUZZLE (case_id, puzzle_no, area_no, puzzle_name, puzzle_type, prompt, answer_key, hint_text, solved_text, prerequisite_puzzle_no, required_free_hands)
VALUES (1, 2, 5, '남은 전력 6', 'POWER', '승강기 조명 배기 순서로 1 또는 0 세 자리를 입력한다.', '110', '4 + 2는 6이다. 승강기와 조명을 켜면 배기를 켤 여유는 없다.', '승강기 전원이 복구되었다. 이제 CCTV 시각과 출입 기록을 대조할 수 있다.', 1, 2);

INSERT INTO PUZZLE (case_id, puzzle_no, area_no, puzzle_name, puzzle_type, prompt, answer_key, hint_text, solved_text, prerequisite_puzzle_no, required_free_hands)
VALUES (1, 3, 4, '승인보다 빠른 문', 'VERIFY', '카메라 시각을 보정하여 해당 출입 차단 명령 코드를 입력한다.', 'B42', '21:17에서 2분을 빼면 21:15이다. 같은 시각의 출입 차단 행을 찾는다.', '문은 승인이 나기 1분 전에 닫혔다. 출입 로그 복사와 비상 탈출 통로가 해제되었다.', 2, 0);

INSERT INTO PUZZLE_CLUE (case_id, puzzle_no, inspection_no)
VALUES (1, 1, 2);

INSERT INTO PUZZLE_CLUE (case_id, puzzle_no, inspection_no)
VALUES (1, 1, 3);

INSERT INTO PUZZLE_CLUE (case_id, puzzle_no, inspection_no)
VALUES (1, 2, 7);

INSERT INTO PUZZLE_CLUE (case_id, puzzle_no, inspection_no)
VALUES (1, 2, 8);

INSERT INTO PUZZLE_CLUE (case_id, puzzle_no, inspection_no)
VALUES (1, 3, 5);

INSERT INTO PUZZLE_CLUE (case_id, puzzle_no, inspection_no)
VALUES (1, 3, 6);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 1, '진입 사다리', 1, 3, 2, 'N', NULL);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 2, '진입 사다리', 3, 1, 2, 'N', NULL);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 3, '보안실 문', 3, 4, 0, 'N', NULL);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 4, '보안실 문', 4, 3, 0, 'N', NULL);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 5, '제어실 문', 3, 5, 0, 'N', NULL);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 6, '제어실 문', 5, 3, 0, 'N', NULL);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 7, '옥상 탈출 사다리', 1, 2, 2, 'N', 3);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 8, '옥상 탈출 사다리', 2, 1, 2, 'N', 3);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 9, '화물 승강기', 3, 6, 0, 'Y', 3);

INSERT INTO PASSAGE (case_id, passage_no, passage_name, from_area_no, to_area_no, min_free_hands, requires_power, unlock_puzzle_no)
VALUES (1, 10, '화물 승강기', 6, 3, 0, 'Y', 3);

INSERT INTO EVIDENCE (case_id, evidence_no, area_no, evidence_name, evidence_note, original_hands, copy_allowed, unlock_puzzle_no)
VALUES (1, 1, 4, 'CCTV 기록 장치', '복사본은 영상 화면만 포함한다. 원본은 시계 보정 이력과 원본 서명을 포함하여 봉쇄 시각을 입증한다.', 2, 'Y', 1);

INSERT INTO EVIDENCE (case_id, evidence_no, area_no, evidence_name, evidence_note, original_hands, copy_allowed, unlock_puzzle_no)
VALUES (1, 2, 4, '출입 명령 로그', '21:15 B42 차단과 21:16 C09 승인이 함께 기록되어 있다. 서버 고정 자료라 복사본만 회수할 수 있다.', NULL, 'Y', 3);

INSERT INTO ENDING (case_id, ending_no, ending_title, ending_text, ending_rank)
VALUES (1, 1, '기록은 남았지만', '영상은 회수되었지만 가져온 자료만으로는 차단 명령과 승인 시각의 관계를 입증하지 못했다. 보고서는 사고로 남았고 돌아오지 못한 사람들의 이름만 조사 수첩에 남는다.', 10);

INSERT INTO ENDING (case_id, ending_no, ending_title, ending_text, ending_rank)
VALUES (1, 2, '닫힌 문을 연 기록', 'CCTV 원본의 보정 이력과 출입 로그를 대조해 승인보다 먼저 문을 잠갔다는 사실을 입증했다. 회수반은 보고서를 수정하고 누락된 사람들의 이름을 공개한다.', 20);

INSERT INTO ENDING_REQUIREMENT (case_id, ending_no, evidence_no, required_form)
VALUES (1, 1, 1, 'ANY');

INSERT INTO ENDING_REQUIREMENT (case_id, ending_no, evidence_no, required_form)
VALUES (1, 2, 1, 'ORIGINAL');

INSERT INTO ENDING_REQUIREMENT (case_id, ending_no, evidence_no, required_form)
VALUES (1, 2, 2, 'COPY');

COMMIT;
PROMPT [DONE] Scenario inserted: 45 rows.
