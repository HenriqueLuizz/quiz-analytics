-- Views para análise de dados do quiz
-- Conecte ao banco 'dw' antes de executar

-- 1. Alternativas Mais Votadas
CREATE OR REPLACE VIEW vw_most_voted_alternatives AS
SELECT
  q.question_id,
  q.text as question_text,
  a.alternativa_letra,
  a.text as alternative_text,
  COUNT(*) AS votes,
  a.is_correct
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id, q.text, a.alternativa_letra, a.text, a.is_correct
ORDER BY votes DESC;

-- 2. Questões Mais Acertadas
CREATE OR REPLACE VIEW vw_most_correct_questions AS
SELECT
  q.question_id,
  q.text as question_text,
  q.dificuldade,
  q.assunto,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) AS accuracy_rate,
  COUNT(*) as total_responses
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id, q.text, q.dificuldade, q.assunto
ORDER BY accuracy_rate DESC;

-- 3. Alunos com maior acerto de primeira tentativa
CREATE OR REPLACE VIEW vw_top_students_first_try AS
SELECT
  s.student_id,
  s.name,
  COUNT(*) AS correct_first_try,
  COUNT(*)::DECIMAL / (SELECT COUNT(DISTINCT question_id) FROM dim_question) as success_rate
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_student s ON r.student_id = s.student_id
WHERE a.is_correct AND r.attempt_number = 1
GROUP BY s.student_id, s.name
ORDER BY correct_first_try DESC;

-- 4. Alunos com maior acerto (todas tentativas)
CREATE OR REPLACE VIEW vw_top_students_all_tries AS
SELECT
  s.student_id,
  s.name,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) AS total_correct,
  COUNT(*) as total_attempts,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) as accuracy_rate
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_student s ON r.student_id = s.student_id
GROUP BY s.student_id, s.name
ORDER BY total_correct DESC;

-- 5. Questões com mais retentativas
CREATE OR REPLACE VIEW vw_questions_most_retries AS
SELECT
  q.question_id,
  q.text as question_text,
  COUNT(*) FILTER (WHERE r.attempt_number > 1) AS retries,
  COUNT(*) as total_attempts,
  COUNT(*) FILTER (WHERE r.attempt_number > 1)::DECIMAL / COUNT(*) as retry_rate
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id, q.text
ORDER BY retries DESC;

-- 6. Questões erradas com maior votos proporcionais
CREATE OR REPLACE VIEW vw_wrong_questions_high_votes AS
SELECT
  q.question_id,
  q.text as question_text,
  SUM(CASE WHEN NOT a.is_correct THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) AS wrong_vote_ratio,
  COUNT(*) as total_votes
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_question q ON a.question_id = q.question_id
GROUP BY q.question_id, q.text
ORDER BY wrong_vote_ratio DESC;

-- 7. Distribuição por assunto
CREATE OR REPLACE VIEW vw_questions_by_subject AS
SELECT
  q.assunto,
  COUNT(DISTINCT q.question_id) AS total_questions,
  COUNT(r.response_id) as total_responses,
  ROUND(100.0 * COUNT(DISTINCT q.question_id) / (SELECT COUNT(*) FROM dim_question), 2) AS question_pct
FROM dim_question q
LEFT JOIN fact_response r ON q.question_id = r.question_id
GROUP BY q.assunto
ORDER BY total_questions DESC;

-- 8. Distribuição por dificuldade
CREATE OR REPLACE VIEW vw_questions_by_difficulty AS
SELECT
  q.dificuldade,
  COUNT(DISTINCT q.question_id) AS total_questions,
  COUNT(r.response_id) as total_responses,
  ROUND(100.0 * COUNT(DISTINCT q.question_id) / (SELECT COUNT(*) FROM dim_question), 2) AS question_pct
FROM dim_question q
LEFT JOIN fact_response r ON q.question_id = r.question_id
GROUP BY q.dificuldade
ORDER BY total_questions DESC;

-- 9. Resumo geral de performance
CREATE OR REPLACE VIEW vw_performance_summary AS
SELECT
  COUNT(DISTINCT s.student_id) as total_students,
  COUNT(DISTINCT q.question_id) as total_questions,
  COUNT(r.response_id) as total_responses,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) as total_correct,
  ROUND(100.0 * SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) / COUNT(r.response_id), 2) as overall_accuracy
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
JOIN dim_student s ON r.student_id = s.student_id
JOIN dim_question q ON r.question_id = q.question_id;

-- 10. Timeline de respostas
CREATE OR REPLACE VIEW vw_response_timeline AS
SELECT
  DATE(r.response_time) as response_date,
  COUNT(*) as responses_per_day,
  SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) as correct_per_day,
  ROUND(100.0 * SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) / COUNT(*), 2) as daily_accuracy
FROM fact_response r
JOIN dim_alternative a ON r.alternative_id = a.alternative_id
GROUP BY DATE(r.response_time)
ORDER BY response_date; 