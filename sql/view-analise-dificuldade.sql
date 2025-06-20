-- View: Análise por Dificuldade
-- Mostra como as alternativas mais votadas variam por dificuldade

CREATE OR REPLACE VIEW vw_analise_dificuldade AS
WITH votos_por_dificuldade AS (
  SELECT 
    dq.dificuldade,
    da.alternativa_letra,
    da.text AS alternativa_texto,
    da.is_correct,
    COUNT(fr.response_id) AS total_votos,
    COUNT(DISTINCT dq.question_id) AS questoes_com_dificuldade,
    ROUND(
      (COUNT(fr.response_id) * 100.0) / 
      (SELECT COUNT(*) FROM fact_response fr2 
       JOIN dim_alternative da2 ON fr2.alternative_id = da2.alternative_id
       JOIN dim_question dq2 ON da2.question_id = dq2.question_id
       WHERE dq2.dificuldade = dq.dificuldade), 2
    ) AS porcentagem_votos_dificuldade
  FROM dim_question dq
  JOIN dim_alternative da ON dq.question_id = da.question_id
  LEFT JOIN fact_response fr ON da.alternative_id = fr.alternative_id
  GROUP BY dq.dificuldade, da.alternativa_letra, da.text, da.is_correct
),
ranking_por_dificuldade AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (
      PARTITION BY dificuldade 
      ORDER BY total_votos DESC
    ) AS ranking_dificuldade
  FROM votos_por_dificuldade
),
estatisticas_dificuldade AS (
  SELECT 
    dificuldade,
    COUNT(DISTINCT question_id) AS total_questoes,
    SUM(total_votos) AS total_votos_dificuldade,
    ROUND(
      (SUM(total_votos) * 100.0) / (SELECT COUNT(*) FROM fact_response), 2
    ) AS porcentagem_votos_geral
  FROM (
    SELECT 
      dq.dificuldade,
      dq.question_id,
      COUNT(fr.response_id) AS total_votos
    FROM dim_question dq
    LEFT JOIN fact_response fr ON dq.question_id = (
      SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
    )
    GROUP BY dq.dificuldade, dq.question_id
  ) sub
  GROUP BY dificuldade
)
SELECT 
  rd.dificuldade,
  ed.total_questoes,
  ed.total_votos_dificuldade,
  ed.porcentagem_votos_geral,
  rd.alternativa_letra,
  rd.alternativa_texto,
  rd.total_votos,
  rd.porcentagem_votos_dificuldade,
  rd.ranking_dificuldade,
  CASE 
    WHEN rd.is_correct THEN '✅ Correta'
    ELSE '❌ Incorreta'
  END AS status_correta,
  CASE 
    WHEN rd.ranking_dificuldade = 1 THEN '🥇 Mais Votada'
    WHEN rd.ranking_dificuldade = 2 THEN '🥈 Segunda'
    WHEN rd.ranking_dificuldade = 3 THEN '🥉 Terceira'
    ELSE 'Outras'
  END AS posicao_ranking
FROM ranking_por_dificuldade rd
JOIN estatisticas_dificuldade ed ON rd.dificuldade = ed.dificuldade
ORDER BY rd.dificuldade, rd.ranking_dificuldade; 