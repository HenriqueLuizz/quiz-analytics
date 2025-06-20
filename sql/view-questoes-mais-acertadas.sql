-- View: Questões Mais Acertadas
-- Mostra as questões com maior índice de acerto

CREATE OR REPLACE VIEW vw_questoes_mais_acertadas AS
WITH acertos_por_questao AS (
  SELECT 
    dq.question_id,
    dq.text AS question_text,
    dq.dificuldade,
    dq.assunto,
    COUNT(fr.response_id) AS total_respostas,
    COUNT(CASE WHEN da.is_correct THEN 1 END) AS total_acertos,
    ROUND(
      (COUNT(CASE WHEN da.is_correct THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_acerto,
    COUNT(DISTINCT fr.student_id) AS estudantes_responderam
  FROM dim_question dq
  LEFT JOIN fact_response fr ON dq.question_id = (
    SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
  )
  LEFT JOIN dim_alternative da ON fr.alternative_id = da.alternative_id
  GROUP BY dq.question_id, dq.text, dq.dificuldade, dq.assunto
),
ranking_acertos AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY taxa_acerto DESC, total_acertos DESC) AS ranking_geral,
    ROW_NUMBER() OVER (
      PARTITION BY dificuldade 
      ORDER BY taxa_acerto DESC, total_acertos DESC
    ) AS ranking_dificuldade,
    ROW_NUMBER() OVER (
      PARTITION BY assunto 
      ORDER BY taxa_acerto DESC, total_acertos DESC
    ) AS ranking_assunto
  FROM acertos_por_questao
)
SELECT 
  question_id,
  question_text,
  dificuldade,
  assunto,
  total_respostas,
  total_acertos,
  taxa_acerto,
  estudantes_responderam,
  ranking_geral,
  ranking_dificuldade,
  ranking_assunto,
  CASE 
    WHEN ranking_geral = 1 THEN '🥇 1º Lugar'
    WHEN ranking_geral = 2 THEN '🥈 2º Lugar'
    WHEN ranking_geral = 3 THEN '🥉 3º Lugar'
    WHEN taxa_acerto >= 80 THEN '✅ Excelente'
    WHEN taxa_acerto >= 60 THEN '🟡 Bom'
    WHEN taxa_acerto >= 40 THEN '🟠 Regular'
    ELSE '🔴 Baixo'
  END AS classificacao_desempenho
FROM ranking_acertos
ORDER BY ranking_geral; 