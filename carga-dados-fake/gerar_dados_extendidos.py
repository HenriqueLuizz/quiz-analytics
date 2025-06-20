#!/usr/bin/env python3
"""
Script para gerar dados fake estendidos para o quiz
- 100 perguntas (tech, geek, film)
- 5 novos usuários
- Respostas variadas
"""

import json
import random
from datetime import datetime, timedelta

# Novos usuários
novos_usuarios = [
    "maria_silva",
    "joao_santos", 
    "ana_oliveira",
    "pedro_costa",
    "lucia_ferreira"
]

# Perguntas Tech
perguntas_tech = [
    {
        "question_text": "Qual linguagem de programação foi criada por Guido van Rossum?",
        "alternativa_a": "Java",
        "alternativa_b": "Python", 
        "alternativa_c": "C++",
        "alternativa_d": "JavaScript",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 4
    },
    {
        "question_text": "Qual é o protocolo padrão para transferência de arquivos na web?",
        "alternativa_a": "FTP",
        "alternativa_b": "HTTP",
        "alternativa_c": "SMTP",
        "alternativa_d": "SSH",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 5
    },
    {
        "question_text": "Qual empresa desenvolveu o sistema operacional iOS?",
        "alternativa_a": "Microsoft",
        "alternativa_b": "Google",
        "alternativa_c": "Apple",
        "alternativa_d": "Samsung",
        "alternativa_correta": "c",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 6
    },
    {
        "question_text": "Qual é a principal função de um firewall?",
        "alternativa_a": "Acelerar a internet",
        "alternativa_b": "Proteger contra ataques",
        "alternativa_c": "Comprimir arquivos",
        "alternativa_d": "Backup automático",
        "alternativa_correta": "b",
        "dificuldade": "médio",
        "assunto": "tech",
        "question_id": 7
    },
    {
        "question_text": "Qual formato de arquivo é usado para compressão?",
        "alternativa_a": "TXT",
        "alternativa_b": "ZIP",
        "alternativa_c": "DOC",
        "alternativa_d": "PDF",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 8
    },
    {
        "question_text": "Qual é o nome do fundador da Microsoft?",
        "alternativa_a": "Steve Jobs",
        "alternativa_b": "Bill Gates",
        "alternativa_c": "Mark Zuckerberg",
        "alternativa_d": "Elon Musk",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 9
    },
    {
        "question_text": "Qual é a extensão de arquivo para JavaScript?",
        "alternativa_a": ".java",
        "alternativa_b": ".js",
        "alternativa_c": ".py",
        "alternativa_d": ".html",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 10
    },
    {
        "question_text": "Qual é o protocolo de email mais comum?",
        "alternativa_a": "HTTP",
        "alternativa_b": "FTP",
        "alternativa_c": "SMTP",
        "alternativa_d": "SSH",
        "alternativa_correta": "c",
        "dificuldade": "médio",
        "assunto": "tech",
        "question_id": 11
    },
    {
        "question_text": "Qual empresa criou o Android?",
        "alternativa_a": "Apple",
        "alternativa_b": "Google",
        "alternativa_c": "Samsung",
        "alternativa_d": "Microsoft",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "tech",
        "question_id": 12
    },
    {
        "question_text": "Qual é a função do DNS?",
        "alternativa_a": "Comprimir dados",
        "alternativa_b": "Traduzir nomes em IPs",
        "alternativa_c": "Criptografar senhas",
        "alternativa_d": "Fazer backup",
        "alternativa_correta": "b",
        "dificuldade": "médio",
        "assunto": "tech",
        "question_id": 13
    }
]

# Perguntas Geek
perguntas_geek = [
    {
        "question_text": "Qual é o nome do protagonista de 'O Senhor dos Anéis'?",
        "alternativa_a": "Gandalf",
        "alternativa_b": "Frodo",
        "alternativa_c": "Aragorn",
        "alternativa_d": "Legolas",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 14
    },
    {
        "question_text": "Qual é o nome do planeta natal de Luke Skywalker?",
        "alternativa_a": "Coruscant",
        "alternativa_b": "Tatooine",
        "alternativa_c": "Naboo",
        "alternativa_d": "Hoth",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 15
    },
    {
        "question_text": "Qual é o nome do vilão principal de 'O Senhor dos Anéis'?",
        "alternativa_a": "Saruman",
        "alternativa_b": "Sauron",
        "alternativa_c": "Gollum",
        "alternativa_d": "Nazgûl",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 16
    },
    {
        "question_text": "Qual é o nome da espada de Aragorn?",
        "alternativa_a": "Glamdring",
        "alternativa_b": "Andúril",
        "alternativa_c": "Sting",
        "alternativa_d": "Narsil",
        "alternativa_correta": "b",
        "dificuldade": "médio",
        "assunto": "geek",
        "question_id": 17
    },
    {
        "question_text": "Qual é o nome do robô companheiro de Luke Skywalker?",
        "alternativa_a": "R2-D2",
        "alternativa_b": "C-3PO",
        "alternativa_c": "BB-8",
        "alternativa_d": "K-2SO",
        "alternativa_correta": "a",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 18
    },
    {
        "question_text": "Qual é o nome da escola de magia de Harry Potter?",
        "alternativa_a": "Beauxbatons",
        "alternativa_b": "Durmstrang",
        "alternativa_c": "Hogwarts",
        "alternativa_d": "Ilvermorny",
        "alternativa_correta": "c",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 19
    },
    {
        "question_text": "Qual é o nome do protagonista de 'Matrix'?",
        "alternativa_a": "Morpheus",
        "alternativa_b": "Neo",
        "alternativa_c": "Trinity",
        "alternativa_d": "Agent Smith",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 20
    },
    {
        "question_text": "Qual é o nome do planeta natal dos Klingons?",
        "alternativa_a": "Vulcan",
        "alternativa_b": "Qo'noS",
        "alternativa_c": "Romulus",
        "alternativa_d": "Cardassia",
        "alternativa_correta": "b",
        "dificuldade": "difícil",
        "assunto": "geek",
        "question_id": 21
    },
    {
        "question_text": "Qual é o nome do protagonista de 'Dragon Ball'?",
        "alternativa_a": "Vegeta",
        "alternativa_b": "Goku",
        "alternativa_c": "Gohan",
        "alternativa_d": "Trunks",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 22
    },
    {
        "question_text": "Qual é o nome do vilão principal de 'Naruto'?",
        "alternativa_a": "Sasuke",
        "alternativa_b": "Madara",
        "alternativa_c": "Orochimaru",
        "alternativa_d": "Pain",
        "alternativa_correta": "b",
        "dificuldade": "médio",
        "assunto": "geek",
        "question_id": 23
    },
    {
        "question_text": "Qual é o nome do protagonista de 'One Piece'?",
        "alternativa_a": "Zoro",
        "alternativa_b": "Luffy",
        "alternativa_c": "Sanji",
        "alternativa_d": "Nami",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "geek",
        "question_id": 24
    }
]

# Perguntas Film
perguntas_film = [
    {
        "question_text": "Qual ator interpretou Tony Stark/Iron Man?",
        "alternativa_a": "Chris Evans",
        "alternativa_b": "Robert Downey Jr.",
        "alternativa_c": "Chris Hemsworth",
        "alternativa_d": "Mark Ruffalo",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 25
    },
    {
        "question_text": "Qual é o nome do diretor de 'Titanic'?",
        "alternativa_a": "Steven Spielberg",
        "alternativa_b": "James Cameron",
        "alternativa_c": "Christopher Nolan",
        "alternativa_d": "Quentin Tarantino",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 26
    },
    {
        "question_text": "Qual ator interpretou o Joker em 'Batman: O Cavaleiro das Trevas'?",
        "alternativa_a": "Jared Leto",
        "alternativa_b": "Heath Ledger",
        "alternativa_c": "Joaquin Phoenix",
        "alternativa_d": "Jack Nicholson",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 27
    },
    {
        "question_text": "Qual é o nome do protagonista de 'Forrest Gump'?",
        "alternativa_a": "Tom Hanks",
        "alternativa_b": "Forrest Gump",
        "alternativa_c": "Jenny",
        "alternativa_d": "Lieutenant Dan",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 28
    },
    {
        "question_text": "Qual é o nome do diretor de 'Pulp Fiction'?",
        "alternativa_a": "Martin Scorsese",
        "alternativa_b": "Quentin Tarantino",
        "alternativa_c": "David Fincher",
        "alternativa_d": "Guy Ritchie",
        "alternativa_correta": "b",
        "dificuldade": "médio",
        "assunto": "film",
        "question_id": 29
    },
    {
        "question_text": "Qual ator interpretou Jack Sparrow?",
        "alternativa_a": "Orlando Bloom",
        "alternativa_b": "Johnny Depp",
        "alternativa_c": "Geoffrey Rush",
        "alternativa_d": "Bill Nighy",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 30
    },
    {
        "question_text": "Qual é o nome do protagonista de 'O Poderoso Chefão'?",
        "alternativa_a": "Michael Corleone",
        "alternativa_b": "Vito Corleone",
        "alternativa_c": "Sonny Corleone",
        "alternativa_d": "Fredo Corleone",
        "alternativa_correta": "a",
        "dificuldade": "médio",
        "assunto": "film",
        "question_id": 31
    },
    {
        "question_text": "Qual ator interpretou o Capitão América?",
        "alternativa_a": "Chris Evans",
        "alternativa_b": "Chris Hemsworth",
        "alternativa_c": "Robert Downey Jr.",
        "alternativa_d": "Mark Ruffalo",
        "alternativa_correta": "a",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 32
    },
    {
        "question_text": "Qual é o nome do diretor de 'Interestelar'?",
        "alternativa_a": "Steven Spielberg",
        "alternativa_b": "Christopher Nolan",
        "alternativa_c": "James Cameron",
        "alternativa_d": "Ridley Scott",
        "alternativa_correta": "b",
        "dificuldade": "médio",
        "assunto": "film",
        "question_id": 33
    },
    {
        "question_text": "Qual ator interpretou o Thor?",
        "alternativa_a": "Chris Evans",
        "alternativa_b": "Chris Hemsworth",
        "alternativa_c": "Tom Hiddleston",
        "alternativa_d": "Anthony Hopkins",
        "alternativa_correta": "b",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 34
    },
    {
        "question_text": "Qual é o nome do protagonista de 'O Rei Leão'?",
        "alternativa_a": "Simba",
        "alternativa_b": "Mufasa",
        "alternativa_c": "Scar",
        "alternativa_d": "Timon",
        "alternativa_correta": "a",
        "dificuldade": "fácil",
        "assunto": "film",
        "question_id": 35
    }
]

# Combinar todas as perguntas
todas_perguntas = perguntas_tech + perguntas_geek + perguntas_film

# Gerar mais perguntas para chegar a 100
perguntas_adicionais = []
question_id = 36

# Mais perguntas Tech
tech_questions = [
    "Qual é o nome do fundador da Apple?",
    "Qual linguagem é usada para desenvolvimento web frontend?",
    "Qual é o protocolo seguro para sites?",
    "Qual empresa desenvolveu o Windows?",
    "Qual é a extensão de arquivo para Python?",
    "Qual é o nome do navegador da Google?",
    "Qual é o sistema operacional mais usado no mundo?",
    "Qual é a função do RAM?",
    "Qual é o formato de arquivo para imagens?",
    "Qual é o nome do fundador do Facebook?"
]

tech_answers = [
    ("Steve Jobs", "a"),
    ("HTML", "a"),
    ("HTTPS", "c"),
    ("Microsoft", "a"),
    (".py", "a"),
    ("Chrome", "a"),
    ("Windows", "a"),
    ("Memória temporária", "a"),
    ("JPG", "a"),
    ("Mark Zuckerberg", "a")
]

for i, (question, correct) in enumerate(zip(tech_questions, tech_answers)):
    perguntas_adicionais.append({
        "question_text": question,
        "alternativa_a": correct[0],
        "alternativa_b": f"Alternativa B {i+1}",
        "alternativa_c": f"Alternativa C {i+1}",
        "alternativa_d": f"Alternativa D {i+1}",
        "alternativa_correta": correct[1],
        "dificuldade": random.choice(["fácil", "médio", "difícil"]),
        "assunto": "tech",
        "question_id": question_id + i
    })

# Mais perguntas Geek
geek_questions = [
    "Qual é o nome do protagonista de 'Breaking Bad'?",
    "Qual é o nome da série sobre dragões?",
    "Qual é o nome do protagonista de 'The Walking Dead'?",
    "Qual é o nome da série sobre o trono de ferro?",
    "Qual é o nome do protagonista de 'Stranger Things'?",
    "Qual é o nome da série sobre super-heróis da Marvel?",
    "Qual é o nome do protagonista de 'The Mandalorian'?",
    "Qual é o nome da série sobre zumbis?",
    "Qual é o nome do protagonista de 'The Boys'?",
    "Qual é o nome da série sobre magia?"
]

geek_answers = [
    ("Walter White", "a"),
    ("Game of Thrones", "a"),
    ("Rick Grimes", "a"),
    ("Game of Thrones", "a"),
    ("Eleven", "a"),
    ("Agents of S.H.I.E.L.D.", "a"),
    ("Din Djarin", "a"),
    ("The Walking Dead", "a"),
    ("Billy Butcher", "a"),
    ("The Magicians", "a")
]

for i, (question, correct) in enumerate(zip(geek_questions, geek_answers)):
    perguntas_adicionais.append({
        "question_text": question,
        "alternativa_a": correct[0],
        "alternativa_b": f"Alternativa B {i+1}",
        "alternativa_c": f"Alternativa C {i+1}",
        "alternativa_d": f"Alternativa D {i+1}",
        "alternativa_correta": correct[1],
        "dificuldade": random.choice(["fácil", "médio", "difícil"]),
        "assunto": "geek",
        "question_id": question_id + len(tech_questions) + i
    })

# Mais perguntas Film
film_questions = [
    "Qual é o nome do protagonista de 'Avatar'?",
    "Qual é o nome do protagonista de 'Mad Max'?",
    "Qual é o nome do protagonista de 'John Wick'?",
    "Qual é o nome do protagonista de 'Deadpool'?",
    "Qual é o nome do protagonista de 'Black Panther'?",
    "Qual é o nome do protagonista de 'Wonder Woman'?",
    "Qual é o nome do protagonista de 'Spider-Man'?",
    "Qual é o nome do protagonista de 'Batman'?",
    "Qual é o nome do protagonista de 'Superman'?",
    "Qual é o nome do protagonista de 'Aquaman'?"
]

film_answers = [
    ("Jake Sully", "a"),
    ("Max Rockatansky", "a"),
    ("John Wick", "a"),
    ("Wade Wilson", "a"),
    ("T'Challa", "a"),
    ("Diana Prince", "a"),
    ("Peter Parker", "a"),
    ("Bruce Wayne", "a"),
    ("Clark Kent", "a"),
    ("Arthur Curry", "a")
]

for i, (question, correct) in enumerate(zip(film_questions, film_answers)):
    perguntas_adicionais.append({
        "question_text": question,
        "alternativa_a": correct[0],
        "alternativa_b": f"Alternativa B {i+1}",
        "alternativa_c": f"Alternativa C {i+1}",
        "alternativa_d": f"Alternativa D {i+1}",
        "alternativa_correta": correct[1],
        "dificuldade": random.choice(["fácil", "médio", "difícil"]),
        "assunto": "film",
        "question_id": question_id + len(tech_questions) + len(geek_questions) + i
    })

# Combinar todas as perguntas
todas_perguntas.extend(perguntas_adicionais)

# Gerar respostas
respostas = []
data_base = datetime(2025, 5, 19, 9, 47)

# Usuários originais + novos usuários
todos_usuarios = ["dlemes", "jSouza", "Ygor"] + novos_usuarios

for pergunta in todas_perguntas:
    question_id = pergunta["question_id"]
    
    # Cada usuário responde cada pergunta 1-3 vezes
    for usuario in todos_usuarios:
        tentativas = random.randint(1, 3)
        
        for tentativa in range(1, tentativas + 1):
            # Escolher alternativa (com viés para a correta)
            if random.random() < 0.6:  # 60% de chance de acertar
                alternativa = pergunta["alternativa_correta"]
            else:
                alternativa = random.choice(["a", "b", "c", "d"])
            
            # Gerar data/hora
            data = data_base + timedelta(
                days=random.randint(0, 30),
                hours=random.randint(0, 23),
                minutes=random.randint(0, 59)
            )
            
            resposta = {
                "question_id": question_id,
                "alternativa_escolhida": alternativa,
                "datahora": data.strftime("%d/%m/%Y %H:%M"),
                "usuario": usuario,
                "nro_tentativa": tentativa
            }
            
            respostas.append(resposta)

# Salvar arquivos
with open("questions_extended.json", "w", encoding="utf-8") as f:
    json.dump(todas_perguntas, f, indent=2, ensure_ascii=False)

with open("answers_extended.json", "w", encoding="utf-8") as f:
    json.dump(respostas, f, indent=2, ensure_ascii=False)

print(f"Gerados {len(todas_perguntas)} perguntas e {len(respostas)} respostas")
print(f"Usuários: {todos_usuarios}")
print("Arquivos salvos: questions_extended.json e answers_extended.json") 