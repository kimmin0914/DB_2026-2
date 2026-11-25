-- 봉쇄구역 회수반 / Oracle 21c XE / UTF-8
-- 조회 전용입니다. 사건 설정은 2_기본 데이터 입력.sql, 예시 이력은 3_예시 이력 입력.sql로 입력합니다.
SET DEFINE OFF
SET PAGESIZE 100
SET LINESIZE 220

-- 1. 접속 계정과 작업 스키마 확인
SELECT USER AS login_user,
       SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS current_schema,
       SYS_CONTEXT('USERENV','CON_NAME') AS container_name
FROM dual;

-- 2. 구역별 조사 장면 (줄바꿈 대사는 content에 저장됨)
SELECT a.area_no, a.area_name, i.inspection_no, i.inspection_type,
       i.title, i.content, i.display_order
FROM AREA a
JOIN INSPECTION i ON i.case_id=a.case_id AND i.area_no=a.area_no
WHERE a.case_id=1
ORDER BY a.area_no,i.display_order;

-- 3. 퍼즐과 선행 퍼즐: 선행 퍼즐이 없는 첫 퍼즐도 유지
SELECT p.puzzle_no,p.puzzle_name,p.puzzle_type,a.area_name,
       pp.puzzle_name AS prerequisite_name,p.required_free_hands,p.hint_text
FROM PUZZLE p
JOIN AREA a ON a.case_id=p.case_id AND a.area_no=p.area_no
LEFT JOIN PUZZLE pp ON pp.case_id=p.case_id AND pp.puzzle_no=p.prerequisite_puzzle_no
WHERE p.case_id=1
ORDER BY p.puzzle_no;

-- 4. 퍼즐에 연결된 단서: M:N 연결 테이블 사용
SELECT p.puzzle_no,p.puzzle_name,i.inspection_no,i.title,i.content
FROM PUZZLE p
JOIN PUZZLE_CLUE pc ON pc.case_id=p.case_id AND pc.puzzle_no=p.puzzle_no
JOIN INSPECTION i ON i.case_id=pc.case_id AND i.inspection_no=pc.inspection_no
WHERE p.case_id=1
ORDER BY p.puzzle_no,i.inspection_no;

-- 5. 방향이 있는 통로와 통과 조건
SELECT p.passage_no,p.passage_name,src.area_name AS from_area,
       dst.area_name AS to_area,p.min_free_hands,p.requires_power,
       up.puzzle_name AS unlock_puzzle
FROM PASSAGE p
JOIN AREA src ON src.case_id=p.case_id AND src.area_no=p.from_area_no
JOIN AREA dst ON dst.case_id=p.case_id AND dst.area_no=p.to_area_no
LEFT JOIN PUZZLE up ON up.case_id=p.case_id AND up.puzzle_no=p.unlock_puzzle_no
WHERE p.case_id=1
ORDER BY p.passage_no;

-- 6. 증거: original_hands=NULL이면 원본 회수 불가, 복사본은 0손
SELECT e.evidence_no,e.evidence_name,a.area_name,e.original_hands,e.copy_allowed,
       up.puzzle_name AS unlock_puzzle,e.evidence_note
FROM EVIDENCE e
JOIN AREA a ON a.case_id=e.case_id AND a.area_no=e.area_no
LEFT JOIN PUZZLE up ON up.case_id=e.case_id AND up.puzzle_no=e.unlock_puzzle_no
WHERE e.case_id=1
ORDER BY e.evidence_no;

-- 7. 결말에 필요한 증거와 형태
SELECT e.ending_no,e.ending_title,e.ending_rank,v.evidence_name,er.required_form
FROM ENDING e
JOIN ENDING_REQUIREMENT er ON er.case_id=e.case_id AND er.ending_no=e.ending_no
JOIN EVIDENCE v ON v.case_id=er.case_id AND v.evidence_no=er.evidence_no
WHERE e.case_id=1
ORDER BY e.ending_rank,er.evidence_no;

-- 8. 모든 회차의 이력: 실패/진행 중도 LEFT JOIN으로 표시
-- 해결 수와 증거 수는 먼저 집계하여 다중 JOIN으로 개수가 부풀지 않게 함
WITH solved AS (
    SELECT case_id,run_no,COUNT(*) AS solved_count,SUM(attempt_count) AS attempts
    FROM RUN_PUZZLE GROUP BY case_id,run_no
), recovered AS (
    SELECT case_id,run_no,COUNT(*) AS evidence_count
    FROM RUN_EVIDENCE GROUP BY case_id,run_no
)
SELECT r.case_id,r.run_no,r.run_status,r.started_at,r.ended_at,
       CASE WHEN r.ended_at IS NOT NULL
            THEN ROUND((CAST(r.ended_at AS DATE)-CAST(r.started_at AS DATE))*86400)
       END AS elapsed_seconds,
       a.area_name AS exit_area,e.ending_title,
       NVL(s.solved_count,0) AS solved_count,NVL(s.attempts,0) AS attempts,
       NVL(v.evidence_count,0) AS evidence_count
FROM PLAY_RUN r
LEFT JOIN AREA a ON a.case_id=r.case_id AND a.area_no=r.exit_area_no
LEFT JOIN ENDING e ON e.case_id=r.case_id AND e.ending_no=r.ending_no
LEFT JOIN solved s ON s.case_id=r.case_id AND s.run_no=r.run_no
LEFT JOIN recovered v ON v.case_id=r.case_id AND v.run_no=r.run_no
WHERE r.case_id=1
ORDER BY r.run_no;

-- 9. 회차별 해결 퍼즐과 제출 횟수 (예시 8행)
SELECT rp.run_no,p.puzzle_name,rp.attempt_count,rp.solved_at
FROM RUN_PUZZLE rp
JOIN PUZZLE p ON p.case_id=rp.case_id AND p.puzzle_no=rp.puzzle_no
WHERE rp.case_id=1
ORDER BY rp.run_no,rp.puzzle_no;

-- 10. 회차별 회수 형태 (예시 3행)
SELECT re.run_no,e.evidence_name,re.recovery_form,
       CASE WHEN re.recovery_form='ORIGINAL' THEN e.original_hands ELSE 0 END AS hands_used
FROM RUN_EVIDENCE re
JOIN EVIDENCE e ON e.case_id=re.case_id AND e.evidence_no=re.evidence_no
WHERE re.case_id=1
ORDER BY re.run_no,re.evidence_no;

-- 11. 원본과 복사본 형태까지 충족한 결말을 우선순위 순으로 조회
-- 예시는 완전 조사 성공 회차 2입니다. 다른 이력을 조회하려면 case_id와 run_no 조건을 변경합니다.
SELECT e.ending_no,e.ending_title,e.ending_rank
FROM ENDING e
WHERE e.case_id=1
  AND EXISTS (SELECT 1 FROM ENDING_REQUIREMENT er WHERE er.case_id=e.case_id AND er.ending_no=e.ending_no)
  AND NOT EXISTS (
      SELECT 1 FROM ENDING_REQUIREMENT er
      WHERE er.case_id=e.case_id AND er.ending_no=e.ending_no
        AND NOT EXISTS (
            SELECT 1 FROM RUN_EVIDENCE re
            WHERE re.case_id=er.case_id AND re.run_no=2 AND re.evidence_no=er.evidence_no
              AND (er.required_form='ANY' OR er.required_form=re.recovery_form)
        )
  )
ORDER BY e.ending_rank DESC;

-- 12. 시연 자료와 기록의 행 수
SELECT 'CASE_FILE' AS table_name,COUNT(*) AS row_count FROM CASE_FILE
UNION ALL SELECT 'AREA',COUNT(*) FROM AREA
UNION ALL SELECT 'INSPECTION',COUNT(*) FROM INSPECTION
UNION ALL SELECT 'PUZZLE',COUNT(*) FROM PUZZLE
UNION ALL SELECT 'PUZZLE_CLUE',COUNT(*) FROM PUZZLE_CLUE
UNION ALL SELECT 'PASSAGE',COUNT(*) FROM PASSAGE
UNION ALL SELECT 'EVIDENCE',COUNT(*) FROM EVIDENCE
UNION ALL SELECT 'ENDING',COUNT(*) FROM ENDING
UNION ALL SELECT 'ENDING_REQUIREMENT',COUNT(*) FROM ENDING_REQUIREMENT
UNION ALL SELECT 'PLAY_RUN',COUNT(*) FROM PLAY_RUN
UNION ALL SELECT 'RUN_PUZZLE',COUNT(*) FROM RUN_PUZZLE
UNION ALL SELECT 'RUN_EVIDENCE',COUNT(*) FROM RUN_EVIDENCE;
