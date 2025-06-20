-- View: Alunos com Maior Quantidade de Acerto de Primeira
-- Ranking dos alunos com mais acertos na primeira tentativa

CREATE OR REPLACE VIEW vw_alunos_acerto_primeira AS
WITH acertos_primeira_tentativa AS (
  SELECT 
    ds.student_id,
    ds.name AS nome_aluno,
    COUNT(fr.response_id) AS total_primeiras_tentativas,
    COUNT(CASE WHEN da.is_correct THEN 1 END) AS acertos_primeira_tentativa,
    ROUND(
      (COUNT(CASE WHEN da.is_correct THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_acerto_primeira,
    COUNT(DISTINCT dq.question_id) AS questoes_respondidas
  FROM dim_student ds
  LEFT JOIN fact_response fr ON ds.student_id = fr.student_id AND fr.attempt_number = 1
  LEFT JOIN dim_alternative da ON fr.alternative_id = da.alternative_id
  LEFT JOIN dim_question dq ON da.question_id = dq.question_id
  GROUP BY ds.student_id, ds.name
),
ranking_alunos AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY acertos_primeira_tentativa DESC, taxa_acerto_primeira DESC) AS ranking_geral,
    ROW_NUMBER() OVER (ORDER BY taxa_acerto_primeira DESC, acertos_primeira_tentativa DESC) AS ranking_taxa
  FROM acertos_primeira_tentativa
)
SELECT 
  student_id,
  nome_aluno,
  total_primeiras_tentativas,
  acertos_primeira_tentativa,
  taxa_acerto_primeira,
  questoes_respondidas,
  ranking_geral,
  ranking_taxa,
  CASE 
    WHEN ranking_geral = 1 THEN '🥇 1º Lugar'
    WHEN ranking_geral = 2 THEN '🥈 2º Lugar'
    WHEN ranking_geral = 3 THEN '🥉 3º Lugar'
    WHEN taxa_acerto_primeira >= 80 THEN '✅ Excelente'
    WHEN taxa_acerto_primeira >= 60 THEN '🟡 Bom'
    WHEN taxa_acerto_primeira >= 40 THEN '🟠 Regular'
    ELSE '🔴 Baixo'
  END AS classificacao_desempenho
FROM ranking_alunos
ORDER BY ranking_geral; 