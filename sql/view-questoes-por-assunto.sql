-- View: Quantidade/Proporção de Questões por Assunto
-- Mostra a distribuição de questões por assunto/tópico

CREATE OR REPLACE VIEW vw_questoes_por_assunto AS
WITH estatisticas_assunto AS (
  SELECT 
    dq.assunto,
    COUNT(DISTINCT dq.question_id) AS total_questoes,
    COUNT(fr.response_id) AS total_respostas,
    COUNT(DISTINCT fr.student_id) AS estudantes_responderam,
    COUNT(CASE WHEN da.is_correct THEN 1 END) AS total_acertos,
    ROUND(
      (COUNT(CASE WHEN da.is_correct THEN 1 END) * 100.0) / COUNT(fr.response_id), 2
    ) AS taxa_acerto_assunto,
    ROUND(
      (COUNT(DISTINCT dq.question_id) * 100.0) / (SELECT COUNT(*) FROM dim_question), 2
    ) AS proporcao_questoes,
    AVG(fr.attempt_number) AS media_tentativas_por_questao
  FROM dim_question dq
  LEFT JOIN fact_response fr ON dq.question_id = (
    SELECT da.question_id FROM dim_alternative da WHERE da.alternative_id = fr.alternative_id
  )
  LEFT JOIN dim_alternative da ON fr.alternative_id = da.alternative_id
  GROUP BY dq.assunto
),
ranking_assunto AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_questoes DESC) AS ranking_quantidade,
    ROW_NUMBER() OVER (ORDER BY taxa_acerto_assunto DESC) AS ranking_desempenho,
    ROW_NUMBER() OVER (ORDER BY media_tentativas_por_questao DESC) AS ranking_dificuldade
  FROM estatisticas_assunto
)
SELECT 
  assunto,
  total_questoes,
  total_respostas,
  estudantes_responderam,
  total_acertos,
  taxa_acerto_assunto,
  proporcao_questoes,
  ROUND(media_tentativas_por_questao, 2) AS media_tentativas_por_questao,
  ranking_quantidade,
  ranking_desempenho,
  ranking_dificuldade,
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
    WHEN ranking_dificuldade = 1 THEN '🔴 Mais Difícil'
    WHEN ranking_dificuldade = 2 THEN '🟠 Segunda'
    WHEN ranking_dificuldade = 3 THEN '🟡 Terceira'
    ELSE '🟢 Fácil'
  END AS classificacao_dificuldade
FROM ranking_assunto
ORDER BY ranking_quantidade; 