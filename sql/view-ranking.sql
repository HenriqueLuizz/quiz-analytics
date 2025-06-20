-- 1. Alternativas Mais Votadas
CREATE VIEW vw_most_voted_alternatives AS
SELECT
  a.question_id,
  a.alternative_id,
  COUNT(*) AS votes
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
GROUP BY a.question_id, a.alternative_id
ORDER BY votes DESC;

-- 2. Questões Mais Acertadas
CREATE VIEW vw_most_correct_questions AS
SELECT
  q.question_id,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END)::DECIMAL
    / COUNT(*) AS accuracy_rate
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id
ORDER BY accuracy_rate DESC;

-- 3. Alunos com maior acerto de primeira tentativa
CREATE VIEW vw_top_students_first_try AS
SELECT
  s.student_id,
  s.name,
  COUNT(*) AS correct_first_try
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_student s ON r.student_id = s.student_id
WHERE a.is_correct AND r.attempt_number = 1
GROUP BY s.student_id, s.name
ORDER BY correct_first_try DESC;

-- 4. Alunos com maior acerto (todas tentativas)
CREATE VIEW vw_top_students_all_tries AS
SELECT
  s.student_id,
  s.name,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) AS total_correct
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_student s ON r.student_id = s.student_id
GROUP BY s.student_id, s.name
ORDER BY total_correct DESC;

-- 5. Questões com mais retentativas
CREATE VIEW vw_questions_most_retries AS
SELECT
  q.question_id,
  COUNT(*) FILTER (WHERE r.attempt_number > 1) AS retries
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id
ORDER BY retries DESC;

-- 6. Questões erradas com maior votos proporcionais
CREATE VIEW vw_wrong_questions_high_votes AS
SELECT
  q.question_id,
  SUM(CASE WHEN NOT a.is_correct THEN 1 ELSE 0 END)::DECIMAL
    / COUNT(*) AS wrong_vote_ratio
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id
ORDER BY wrong_vote_ratio DESC;

-- 7. Distribuição por assunto (supondo coluna 'subject' em dim_question)
CREATE VIEW vw_questions_by_subject AS
SELECT
  subject,
  COUNT(*) AS total,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM dim_question
GROUP BY subject;

-- 8. Distribuição por dificuldade (supondo coluna 'difficulty')
CREATE VIEW vw_questions_by_difficulty AS
SELECT
  difficulty,
  COUNT(*) AS total,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM dim_question
GROUP BY difficulty;
