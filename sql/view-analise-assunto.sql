-- View: Análise por Assunto
-- Mostra como as alternativas mais votadas variam por assunto/tópico

CREATE OR REPLACE VIEW vw_analise_assunto AS
WITH votos_por_assunto AS (
  SELECT 
    dq.assunto,
    da.alternativa_letra,
    da.text AS alternativa_texto,
    da.is_correct,
    COUNT(fr.response_id) AS total_votos,
    COUNT(DISTINCT dq.question_id) AS questoes_com_assunto,
    ROUND(
      (COUNT(fr.response_id) * 100.0) / 
      (SELECT COUNT(*) FROM fact_response fr2 
       JOIN dim_alternative da2 ON fr2.alternative_id = da2.alternative_id
       JOIN dim_question dq2 ON da2.question_id = dq2.question_id
       WHERE dq2.assunto = dq.assunto), 2
    ) AS porcentagem_votos_assunto
  FROM dim_question dq
  JOIN dim_alternative da ON dq.question_id = da.question_id
  LEFT JOIN fact_response fr ON da.alternative_id = fr.alternative_id
  GROUP BY dq.assunto, da.alternativa_letra, da.text, da.is_correct
),
ranking_por_assunto AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (
      PARTITION BY assunto 
      ORDER BY total_votos DESC
    ) AS ranking_assunto
  FROM votos_por_assunto
),
estatisticas_assunto AS (
  SELECT 
    assunto,
    COUNT(DISTINCT question_id) AS total_questoes,
    SUM(total_votos) AS total_votos_assunto,
    ROUND(
      (SUM(total_votos) * 100.0) / (SELECT COUNT(*) FROM fact_response), 2
    ) AS porcentagem_votos_geral
  FROM (
    SELECT 
      dq.assunto,
      dq.question_id,
      COUNT(fr.response_id) AS total_votos
    FROM dim_question dq
    LEFT JOIN fact_response fr ON dq.question_id = (
      SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
    )
    GROUP BY dq.assunto, dq.question_id
  ) sub
  GROUP BY assunto
)
SELECT 
  ra.assunto,
  ea.total_questoes,
  ea.total_votos_assunto,
  ea.porcentagem_votos_geral,
  ra.alternativa_letra,
  ra.alternativa_texto,
  ra.total_votos,
  ra.porcentagem_votos_assunto,
  ra.ranking_assunto,
  CASE 
    WHEN ra.is_correct THEN '✅ Correta'
    ELSE '❌ Incorreta'
  END AS status_correta,
  CASE 
    WHEN ra.ranking_assunto = 1 THEN '🥇 Mais Votada'
    WHEN ra.ranking_assunto = 2 THEN '🥈 Segunda'
    WHEN ra.ranking_assunto = 3 THEN '🥉 Terceira'
    ELSE 'Outras'
  END AS posicao_ranking
FROM ranking_por_assunto ra
JOIN estatisticas_assunto ea ON ra.assunto = ea.assunto
ORDER BY ra.assunto, ra.ranking_assunto; 