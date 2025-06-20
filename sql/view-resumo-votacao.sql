-- View: Resumo Geral de Votação
-- Mostra estatísticas gerais sobre as votações

CREATE OR REPLACE VIEW vw_resumo_votacao AS
WITH estatisticas_gerais AS (
  SELECT 
    COUNT(DISTINCT dq.question_id) AS total_questoes,
    COUNT(DISTINCT ds.student_id) AS total_estudantes,
    COUNT(fr.response_id) AS total_respostas,
    COUNT(DISTINCT fr.student_id) AS estudantes_responderam,
    ROUND(
      (COUNT(DISTINCT fr.student_id) * 100.0) / COUNT(DISTINCT ds.student_id), 2
    ) AS taxa_participacao
  FROM dim_question dq
  CROSS JOIN dim_student ds
  LEFT JOIN fact_response fr ON ds.student_id = fr.student_id
),
estatisticas_por_questao AS (
  SELECT 
    dq.question_id,
    dq.text AS question_text,
    dq.dificuldade,
    dq.assunto,
    COUNT(fr.response_id) AS total_votos_questao,
    COUNT(DISTINCT fr.student_id) AS estudantes_responderam,
    ROUND(
      (COUNT(fr.response_id) * 100.0) / 
      (SELECT COUNT(*) FROM fact_response), 2
    ) AS porcentagem_votos_geral
  FROM dim_question dq
  LEFT JOIN fact_response fr ON dq.question_id = (
    SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
  )
  GROUP BY dq.question_id, dq.text, dq.dificuldade, dq.assunto
),
alternativa_mais_votada AS (
  SELECT 
    dq.question_id,
    da.alternativa_letra,
    da.text AS alternativa_texto,
    COUNT(fr.response_id) AS votos,
    da.is_correct,
    ROW_NUMBER() OVER (
      PARTITION BY dq.question_id 
      ORDER BY COUNT(fr.response_id) DESC
    ) AS ranking
  FROM dim_question dq
  JOIN dim_alternative da ON dq.question_id = da.question_id
  LEFT JOIN fact_response fr ON da.alternative_id = fr.alternative_id
  GROUP BY dq.question_id, da.alternativa_letra, da.text, da.is_correct
)
SELECT 
  eg.total_questoes,
  eg.total_estudantes,
  eg.total_respostas,
  eg.estudantes_responderam,
  eg.taxa_participacao,
  eq.question_text,
  eq.dificuldade,
  eq.assunto,
  eq.total_votos_questao,
  eq.estudantes_responderam AS estudantes_por_questao,
  eq.porcentagem_votos_geral,
  amv.alternativa_letra AS alternativa_mais_votada,
  amv.alternativa_texto AS texto_alternativa_mais_votada,
  amv.votos AS votos_alternativa_mais_votada,
  CASE 
    WHEN amv.is_correct THEN '✅ Correta'
    ELSE '❌ Incorreta'
  END AS status_alternativa_mais_votada
FROM estatisticas_gerais eg
CROSS JOIN estatisticas_por_questao eq
LEFT JOIN alternativa_mais_votada amv ON eq.question_id = amv.question_id AND amv.ranking = 1
ORDER BY eq.question_id; 