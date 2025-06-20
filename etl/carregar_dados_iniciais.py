import json
import redis
import os

# Configurações de conexão
REDIS_HOST = 'redis'
REDIS_PORT = 6379

def carregar_questions():
    """Carrega as questões do JSON para o Redis"""
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    
    # Carrega questões
    with open('/app/carga-dados-fake/questions.json', 'r') as f:
        questions = json.load(f)
    
    for question in questions:
        key = f"question:{question['question_id']}"
        r.hset(key, mapping=question)
        print(f"Questão {question['question_id']} carregada: {question['question_text'][:50]}...")

def carregar_answers():
    """Carrega as respostas do JSON para o Redis"""
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    
    # Carrega respostas
    with open('/app/carga-dados-fake/answers.json', 'r') as f:
        answers = json.load(f)
    
    for answer in answers:
        key = f"answer:{answer['usuario']}:{answer['question_id']}:{answer['nro_tentativa']}"
        r.hset(key, mapping=answer)
        print(f"Resposta carregada: {answer['usuario']} - Questão {answer['question_id']}")

if __name__ == "__main__":
    print("Carregando dados iniciais...")
    carregar_questions()
    carregar_answers()
    print("Dados carregados com sucesso!") 