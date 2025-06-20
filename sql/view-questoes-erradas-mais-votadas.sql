-- View: Questões Erradas com Maior Quantidade de Votos
-- Mostra questões onde a alternativa incorreta foi mais votada

CREATE OR REPLACE VIEW vw_questoes_erradas_mais_votadas AS
WITH votos_alternativas_incorretas AS (
  SELECT 
    dq.question_id,
    dq.text AS question_text,
    dq.dificuldade,
    dq.assunto,
    da.alternativa_letra,
    da.text AS alternativa_texto,
    da.is_correct,
    COUNT(fr.response_id) AS total_votos_alternativa,
    ROUND(
      (COUNT(fr.response_id) * 100.0) / 
      (SELECT COUNT(*) FROM fact_response fr2 
       JOIN dim_alternative da2 ON fr2.alternative_id = da2.alternative_id 
       WHERE da2.question_id = dq.question_id), 2
    ) AS porcentagem_votos_alternativa,
    COUNT(DISTINCT fr.student_id) AS estudantes_votaram_alternativa
  FROM dim_question dq
  JOIN dim_alternative da ON dq.question_id = da.question_id
  LEFT JOIN fact_response fr ON da.alternative_id = fr.alternative_id
  GROUP BY 
    dq.question_id, dq.text, dq.dificuldade, dq.assunto,
    da.alternativa_letra, da.text, da.is_correct
),
ranking_alternativas_incorretas AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (
      PARTITION BY question_id 
      ORDER BY total_votos_alternativa DESC
    ) AS ranking_alternativa,
    ROW_NUMBER() OVER (
      ORDER BY 
        CASE WHEN NOT is_correct THEN total_votos_alternativa END DESC,
        porcentagem_votos_alternativa DESC
    ) AS ranking_geral_incorretas
  FROM votos_alternativas_incorretas
),
questoes_com_maior_voto_incorreto AS (
  SELECT 
    question_id,
    question_text,
    dificuldade,
    assunto,
    alternativa_letra,
    alternativa_texto,
    total_votos_alternativa,
    porcentagem_votos_alternativa,
    estudantes_votaram_alternativa,
    ranking_alternativa,
    ranking_geral_incorretas,
    CASE 
      WHEN ranking_alternativa = 1 AND NOT is_correct THEN '❌ Alternativa Incorreta Mais Votada'
      WHEN ranking_alternativa = 1 AND is_correct THEN '✅ Alternativa Correta Mais Votada'
      WHEN NOT is_correct THEN '❌ Alternativa Incorreta'
      ELSE '✅ Alternativa Correta'
    END AS status_alternativa
  FROM ranking_alternativas_incorretas
  WHERE ranking_alternativa = 1 OR NOT is_correct
)
SELECT 
  question_id,
  question_text,
  dificuldade,
  assunto,
  alternativa_letra,
  alternativa_texto,
  total_votos_alternativa,
  porcentagem_votos_alternativa,
  estudantes_votaram_alternativa,
  ranking_alternativa,
  ranking_geral_incorretas,
  status_alternativa,
  CASE 
    WHEN ranking_geral_incorretas = 1 THEN '🥇 Mais Problemática'
    WHEN ranking_geral_incorretas = 2 THEN '🥈 Segunda'
    WHEN ranking_geral_incorretas = 3 THEN '🥉 Terceira'
    WHEN porcentagem_votos_alternativa >= 50 THEN '🔴 Muito Problemática'
    WHEN porcentagem_votos_alternativa >= 30 THEN '🟠 Problemática'
    WHEN porcentagem_votos_alternativa >= 10 THEN '🟡 Moderada'
    ELSE '🟢 Pouco Problemática'
  END AS classificacao_problema
FROM questoes_com_maior_voto_incorreto
ORDER BY ranking_geral_incorretas; 