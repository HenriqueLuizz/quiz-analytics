-- View: Quantidade/Proporção de Questões por Dificuldade
-- Mostra a distribuição de questões por nível de dificuldade

CREATE OR REPLACE VIEW vw_questoes_por_dificuldade AS
WITH estatisticas_dificuldade AS (
  SELECT 
    dq.dificuldade,
    COUNT(DISTINCT dq.question_id) AS total_questoes,
    COUNT(fr.response_id) AS total_respostas,
    COUNT(DISTINCT fr.student_id) AS estudantes_responderam,
    COUNT(CASE WHEN da.is_correct THEN 1 END) AS total_acertos,
    ROUND(
      (COUNT(CASE WHEN da.is_correct THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_acerto_dificuldade,
    ROUND(
      (COUNT(DISTINCT dq.question_id) * 100.0) / (SELECT COUNT(*) FROM dim_question), 2
    ) AS proporcao_questoes,
    AVG(fr.attempt_number) AS media_tentativas_por_questao,
    COUNT(CASE WHEN fr.attempt_number > 1 THEN 1 END) AS total_retentativas,
    ROUND(
      (COUNT(CASE WHEN fr.attempt_number > 1 THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_retentativa
  FROM dim_question dq
  LEFT JOIN fact_response fr ON dq.question_id = (
    SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
  )
  LEFT JOIN dim_alternative da ON fr.alternative_id = da.alternative_id
  GROUP BY dq.dificuldade
),
ranking_dificuldade AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_questoes DESC) AS ranking_quantidade,
    ROW_NUMBER() OVER (ORDER BY taxa_acerto_dificuldade DESC) AS ranking_desempenho,
    ROW_NUMBER() OVER (ORDER BY media_tentativas_por_questao DESC) AS ranking_dificuldade_real
  FROM estatisticas_dificuldade
)
SELECT 
  dificuldade,
  total_questoes,
  total_respostas,
  estudantes_responderam,
  total_acertos,
  taxa_acerto_dificuldade,
  proporcao_questoes,
  ROUND(media_tentativas_por_questao, 2) AS media_tentativas_por_questao,
  total_retentativas,
  taxa_retentativa,
  ranking_quantidade,
  ranking_desempenho,
  ranking_dificuldade_real,
  CASE 
    WHEN ranking_quantidade = 1 THEN '🥇 Mais Questões'
    WHEN ranking_quantidade = 2 THEN '🥈 Segunda'
    WHEN ranking_quantidade = 3 THEN '🥉 Terceira'
    ELSE 'Outros'
  END AS classificacao_quantidade,
  CASE 
    WHEN ranking_desempenho = 1 THEN '🥇 Melhor Desempenho'
    WHEN ranking_desempenho = 2 THEN '🥈 Segunda'
    WHEN ranking_desempenho = 3 THEN '🥉 Terceira'
    ELSE 'Outros'
  END AS classificacao_desempenho,
  CASE 
    WHEN ranking_dificuldade_real = 1 THEN '🔴 Mais Difícil'
    WHEN ranking_dificuldade_real = 2 THEN '🟠 Segunda'
    WHEN ranking_dificuldade_real = 3 THEN '🟡 Terceira'
    ELSE '🟢 Fácil'
  END AS classificacao_dificuldade_real
FROM ranking_dificuldade
ORDER BY ranking_quantidade; 