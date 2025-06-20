-- View: Alternativas Mais Votadas por Questão
-- Mostra quais alternativas receberam mais votos para cada questão

CREATE OR REPLACE VIEW vw_alternativas_mais_votadas AS
WITH votos_por_alternativa AS (
  SELECT 
    dq.question_id,
    dq.text AS question_text,
    dq.dificuldade,
    dq.assunto,
    da.alternative_id,
    da.text AS alternativa_texto,
    da.alternativa_letra,
    da.is_correct,
    COUNT(fr.response_id) AS total_votos,
    ROUND(
      (COUNT(fr.response_id) * 100.0) / 
      (SELECT COUNT(*) FROM fact_response fr2 
       JOIN dim_alternative da2 ON fr2.alternative_id = da2.alternative_id 
       WHERE da2.question_id = dq.question_id), 2
    ) AS porcentagem_votos
  FROM dim_question dq
  JOIN dim_alternative da ON dq.question_id = da.question_id
  LEFT JOIN fact_response fr ON da.alternative_id = fr.alternative_id
  GROUP BY 
    dq.question_id, dq.text, dq.dificuldade, dq.assunto,
    da.alternative_id, da.text, da.alternativa_letra, da.is_correct
),
ranking_alternativas AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (
      PARTITION BY question_id 
      ORDER BY total_votos DESC, alternativa_letra
    ) AS ranking
  FROM votos_por_alternativa
)
SELECT 
  question_id,
  question_text,
  dificuldade,
  assunto,
  alternative_id,
  alternativa_texto,
  alternativa_letra,
  is_correct,
  total_votos,
  porcentagem_votos,
  ranking,
  CASE 
    WHEN ranking = 1 THEN 'Mais Votada'
    WHEN ranking = 2 THEN 'Segunda Mais Votada'
    WHEN ranking = 3 THEN 'Terceira Mais Votada'
    ELSE 'Outras'
  END AS posicao_ranking
FROM ranking_alternativas
ORDER BY question_id, ranking; 