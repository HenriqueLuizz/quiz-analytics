-- dimensões
CREATE TABLE dim_question (
  question_id   SERIAL PRIMARY KEY,
  text          TEXT
);

CREATE TABLE dim_alternative (
  alternative_id SERIAL PRIMARY KEY,
  question_id    INT REFERENCES dim_question,
  text            TEXT,
  is_correct      BOOLEAN
);

CREATE TABLE dim_student (
  student_id SERIAL PRIMARY KEY,
  name       TEXT
);

