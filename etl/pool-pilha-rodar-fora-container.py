import time
import redis
import psycopg2
import os
from datetime import datetime
 
# Configurações de conexão
REDIS_HOST = 'redis' 
REDIS_PORT = 6379

PG_HOST = 'postgres' 
PG_PORT = 5432
PG_DB = 'dw'
PG_USER = 'dw_user'
PG_PASSWORD = 'dw_pass'

def create_tables_if_not_exists(conn):
    """Cria as tabelas do schema se não existirem"""
    with conn.cursor() as cur:
        # Tabela dim_question
        cur.execute("""
            CREATE TABLE IF NOT EXISTS dim_question (
                question_id SERIAL PRIMARY KEY,
                text TEXT,
                dificuldade TEXT,
                assunto TEXT
            );
        """)
        
        # Tabela dim_alternative
        cur.execute("""
            CREATE TABLE IF NOT EXISTS dim_alternative (
                alternative_id SERIAL PRIMARY KEY,
                question_id INT REFERENCES dim_question(question_id),
                text TEXT,
                is_correct BOOLEAN,
                alternativa_letra CHAR(1)
            );
        """)
        
        # Tabela dim_student
        cur.execute("""
            CREATE TABLE IF NOT EXISTS dim_student (
                student_id SERIAL PRIMARY KEY,
                name TEXT UNIQUE
            );
        """)
        
        # Tabela fact_response
        cur.execute("""
            CREATE TABLE IF NOT EXISTS fact_response (
                response_id SERIAL PRIMARY KEY,
                student_id INT REFERENCES dim_student(student_id),
                alternative_id INT REFERENCES dim_alternative(alternative_id),
                response_time TIMESTAMP,
                attempt_number INT,
                question_id INT REFERENCES dim_question(question_id)
            );
        """)
        
    conn.commit()

def get_or_create_student(conn, student_name):
    """Obtém ou cria um estudante"""
    with conn.cursor() as cur:
        try:
            # Tenta encontrar o estudante
            cur.execute("SELECT student_id FROM dim_student WHERE name = %s", (student_name,))
            result = cur.fetchone()
            
            if result:
                return result[0]
            else:
                # Cria novo estudante
                cur.execute("INSERT INTO dim_student (name) VALUES (%s) RETURNING student_id", (student_name,))
                return cur.fetchone()[0]
        except Exception as e:
            conn.rollback()
            raise e

def get_or_create_question(conn, question_data, question_id_from_key):
    """Obtém ou cria uma questão"""
    with conn.cursor() as cur:
        try:
            # Tenta encontrar a questão
            cur.execute("SELECT question_id FROM dim_question WHERE question_id = %s", (question_id_from_key,))
            result = cur.fetchone()
            
            if result:
                return result[0]
            else:
                # Cria nova questão
                cur.execute("""
                    INSERT INTO dim_question (question_id, text, dificuldade, assunto) 
                    VALUES (%s, %s, %s, %s) RETURNING question_id
                """, (
                    question_id_from_key,
                    question_data['question_text'],
                    question_data['dificuldade'],
                    question_data['assunto']
                ))
                return cur.fetchone()[0]
        except Exception as e:
            conn.rollback()
            raise e

def get_or_create_alternatives(conn, question_id, question_data):
    """Obtém ou cria as alternativas de uma questão"""
    alternatives = {
        'a': question_data['alternativa_a'],
        'b': question_data['alternativa_b'],
        'c': question_data['alternativa_c'],
        'd': question_data['alternativa_d']
    }
    
    correct_alternative = question_data['alternativa_correta']
    alternative_ids = {}
    
    with conn.cursor() as cur:
        try:
            for letter, text in alternatives.items():
                # Verifica se a alternativa já existe
                cur.execute("""
                    SELECT alternative_id FROM dim_alternative 
                    WHERE question_id = %s AND alternativa_letra = %s
                """, (question_id, letter))
                result = cur.fetchone()
                
                if result:
                    alternative_ids[letter] = result[0]
                else:
                    # Cria nova alternativa
                    is_correct = (letter == correct_alternative)
                    cur.execute("""
                        INSERT INTO dim_alternative (question_id, text, is_correct, alternativa_letra) 
                        VALUES (%s, %s, %s, %s) RETURNING alternative_id
                    """, (question_id, text, is_correct, letter))
                    alternative_ids[letter] = cur.fetchone()[0]
        except Exception as e:
            conn.rollback()
            raise e
    
    return alternative_ids

def sync_questions_from_redis(conn, r):
    """Sincroniza questões do Redis para PostgreSQL"""
    print("Sincronizando questões...")
    
    try:
        # Busca todas as questões no Redis
        question_keys = r.keys("question:*")
        
        for key in question_keys:
            question_data = r.hgetall(key)
            if question_data:
                # Extrai o question_id da chave (ex: "question:1" -> 1)
                question_id_from_key = int(key.split(":")[1])
                
                # Cria ou atualiza a questão
                question_id = get_or_create_question(conn, question_data, question_id_from_key)
                
                # Cria ou atualiza as alternativas
                alternative_ids = get_or_create_alternatives(conn, question_id, question_data)
                
                print(f"Questão {question_id} sincronizada com {len(alternative_ids)} alternativas")
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e

def sync_answers_from_redis(conn, r):
    """Sincroniza respostas do Redis para PostgreSQL"""
    print("Sincronizando respostas...")
    try:
        # Busca todas as respostas no Redis
        answer_keys = r.keys("answer:*")
        for key in answer_keys:
            answer_data = r.hgetall(key)
            if answer_data:
                try:
                    # Obtém ou cria o estudante
                    student_id = get_or_create_student(conn, answer_data['usuario'])
                    # Obtém a questão e alternativa
                    question_id = int(answer_data['question_id'])
                    alternativa_escolhida = answer_data['alternativa_escolhida']
                    # Busca o alternative_id correspondente
                    with conn.cursor() as cur:
                        cur.execute("""
                            SELECT alternative_id FROM dim_alternative 
                            WHERE question_id = %s AND alternativa_letra = %s
                        """, (question_id, alternativa_escolhida))
                        result = cur.fetchone()
                        if result:
                            alternative_id = result[0]
                            # Verifica se a resposta já existe
                            cur.execute("""
                                SELECT response_id FROM fact_response 
                                WHERE student_id = %s AND alternative_id = %s AND attempt_number = %s
                            """, (student_id, alternative_id, int(answer_data['nro_tentativa'])))
                            if not cur.fetchone():
                                # Converte a data/hora
                                try:
                                    response_time = datetime.strptime(answer_data['datahora'], '%d/%m/%Y %H:%M')
                                except:
                                    response_time = datetime.now()
                                # Insere a resposta
                                cur.execute("""
                                    INSERT INTO fact_response 
                                    (student_id, alternative_id, response_time, attempt_number) 
                                    VALUES (%s, %s, %s, %s)
                                """, (
                                    student_id, 
                                    alternative_id, 
                                    response_time, 
                                    int(answer_data['nro_tentativa'])
                                ))
                                print(f"Resposta sincronizada: {answer_data['usuario']} - Questão {question_id}")
                except Exception as e:
                    print(f"Erro ao sincronizar resposta {key}: {e}")
                    continue
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e

def main():
    print("Iniciando sincronização Redis -> PostgreSQL...")
    
    # Conexão com Redis
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    
    # Conexão com Postgres
    pg_conn = psycopg2.connect(
        host=PG_HOST,
        port=PG_PORT,
        dbname=PG_DB,
        user=PG_USER,
        password=PG_PASSWORD
    )

    # Cria as tabelas se não existirem
    create_tables_if_not_exists(pg_conn)

    print("Iniciando loop de sincronização...")
    while True:
        try:
            # Sincroniza questões
            sync_questions_from_redis(pg_conn, r)
            
            # Sincroniza respostas
            sync_answers_from_redis(pg_conn, r)
            
            print("Sincronização concluída. Aguardando 30 segundos...")
            time.sleep(30)  # Aguarda 30 segundos entre cada iteração
            
        except Exception as e:
            print(f"Erro na sincronização: {e}")
            time.sleep(10)  # Aguarda 10 segundos em caso de erro

if __name__ == "__main__":
    main()