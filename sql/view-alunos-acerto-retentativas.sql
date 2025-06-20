-- View: Alunos com Maior Quantidade de Acerto Considerando Retentativas
-- Ranking dos alunos considerando todas as tentativas

CREATE OR REPLACE VIEW vw_alunos_acerto_retentativas AS
WITH acertos_todas_tentativas AS (
  SELECT 
    ds.student_id,
    ds.name AS nome_aluno,
    COUNT(fr.response_id) AS total_tentativas,
    COUNT(CASE WHEN da.is_correct THEN 1 END) AS total_acertos,
    ROUND(
      (COUNT(CASE WHEN da.is_correct THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_acerto_geral,
    COUNT(DISTINCT dq.question_id) AS questoes_respondidas,
    COUNT(DISTINCT CASE WHEN fr.attempt_number > 1 THEN dq.question_id END) AS questoes_com_retentativa,
    AVG(fr.attempt_number) AS media_tentativas_por_questao
  FROM dim_student ds
  LEFT JOIN fact_response fr ON ds.student_id = fr.student_id
  LEFT JOIN dim_alternative da ON fr.alternative_id = da.alternative_id
  LEFT JOIN dim_question dq ON da.question_id = dq.question_id
  GROUP BY ds.student_id, ds.name
),
ranking_alunos AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_acertos DESC, taxa_acerto_geral DESC) AS ranking_geral,
    ROW_NUMBER() OVER (ORDER BY taxa_acerto_geral DESC, total_acertos DESC) AS ranking_taxa
  FROM acertos_todas_tentativas
)
SELECT 
  student_id,
  nome_aluno,
  total_tentativas,
  total_acertos,
  taxa_acerto_geral,
  questoes_respondidas,
  questoes_com_retentativa,
  ROUND(media_tentativas_por_questao, 2) AS media_tentativas_por_questao,
  ranking_geral,
  ranking_taxa,
  CASE 
    WHEN ranking_geral = 1 THEN '🥇 1º Lugar'
    WHEN ranking_geral = 2 THEN '🥈 2º Lugar'
    WHEN ranking_geral = 3 THEN '🥉 3º Lugar'
    WHEN taxa_acerto_geral >= 80 THEN '✅ Excelente'
    WHEN taxa_acerto_geral >= 60 THEN '🟡 Bom'
    WHEN taxa_acerto_geral >= 40 THEN '🟠 Regular'
    ELSE '🔴 Baixo'
  END AS classificacao_desempenho
FROM ranking_alunos
ORDER BY ranking_geral; 