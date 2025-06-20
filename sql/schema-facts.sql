-- fato de respostas/votos
CREATE TABLE fact_response (
  response_id     SERIAL PRIMARY KEY,
  student_id      INT REFERENCES dim_student,
  alternative_id  INT REFERENCES dim_alternative,
  response_time   TIMESTAMP,
  attempt_number  INT
);