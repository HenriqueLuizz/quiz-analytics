-- View: Questões com Mais Retentativas
-- Mostra as questões que tiveram mais tentativas

CREATE OR REPLACE VIEW vw_questoes_mais_retentativas AS
WITH retentativas_por_questao AS (
  SELECT 
    dq.question_id,
    dq.text AS question_text,
    dq.dificuldade,
    dq.assunto,
    COUNT(fr.response_id) AS total_respostas,
    COUNT(DISTINCT fr.student_id) AS estudantes_responderam,
    COUNT(CASE WHEN fr.attempt_number > 1 THEN 1 END) AS total_retentativas,
    ROUND(
      (COUNT(CASE WHEN fr.attempt_number > 1 THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_retentativa,
    AVG(fr.attempt_number) AS media_tentativas_por_estudante,
    MAX(fr.attempt_number) AS max_tentativas
  FROM dim_question dq
  LEFT JOIN fact_response fr ON dq.question_id = (
    SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
  )
  GROUP BY dq.question_id, dq.text, dq.dificuldade, dq.assunto
),
ranking_retentativas AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_retentativas DESC, taxa_retentativa DESC) AS ranking_geral,
    ROW_NUMBER() OVER (
      PARTITION BY dificuldade 
      ORDER BY total_retentativas DESC, taxa_retentativa DESC
    ) AS ranking_dificuldade,
    ROW_NUMBER() OVER (
      PARTITION BY assunto 
      ORDER BY total_retentativas DESC, taxa_retentativa DESC
    ) AS ranking_assunto
  FROM retentativas_por_questao
)
SELECT 
  question_id,
  question_text,
  dificuldade,
  assunto,
  total_respostas,
  estudantes_responderam,
  total_retentativas,
  taxa_retentativa,
  ROUND(media_tentativas_por_estudante, 2) AS media_tentativas_por_estudante,
  max_tentativas,
  ranking_geral,
  ranking_dificuldade,
  ranking_assunto,
  CASE 
    WHEN ranking_geral = 1 THEN '🥇 Mais Retentativas'
    WHEN ranking_geral = 2 THEN '🥈 Segunda'
    WHEN ranking_geral = 3 THEN '🥉 Terceira'
    WHEN taxa_retentativa >= 50 THEN '🔴 Muito Difícil'
    WHEN taxa_retentativa >= 30 THEN '🟠 Difícil'
    WHEN taxa_retentativa >= 10 THEN '🟡 Moderado'
    ELSE '🟢 Fácil'
  END AS classificacao_dificuldade
FROM ranking_retentativas
ORDER BY ranking_geral; 