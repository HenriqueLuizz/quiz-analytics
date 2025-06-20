# Quiz Analytics System

Este projeto é uma solução completa para análise de dados de quizzes, integrando API, Redis, RedisGears, ETL, PostgreSQL (Data Warehouse) e Metabase para visualização. Todo o sistema é orquestrado via Docker Compose.

## Arquitetura

```
Usuário → [API FastAPI] → [Redis] → [RedisGears] → [ETL Python] → [PostgreSQL] → [Metabase]
```

- **API (FastAPI)**: Recebe e armazena perguntas, respostas e votos no Redis.
- **Redis**: Armazena dados temporários e serve de buffer para o ETL.
- **RedisGears**: Captura eventos no Redis e pode acionar fluxos automáticos.
- **ETL (Python)**: Sincroniza dados do Redis para o PostgreSQL, estruturando-os em um esquema estrela (star schema) para análise.
- **PostgreSQL**: Data Warehouse para análises e visualizações.
- **Metabase**: Dashboard para visualização dos dados e insights.

## Estrutura dos diretórios

```
quiz-analytics/
  ├── api/                # Código da API FastAPI
  ├── etl/                # Scripts ETL e carga inicial
  ├── metabase/           # Configuração do Metabase
  ├── sql/                # Scripts SQL de views e schema
  ├── carga-dados-fake/   # Dados fake para testes
  ├── docker-compose.yml  # Orquestração dos serviços
  └── README.md           # Este arquivo
```

## Como rodar localmente

1. **Clone o repositório:**
   ```bash
   git clone <repo-url>
   cd quiz-analytics
   ```

2. **Configure variáveis de ambiente:**
   - Copie o arquivo `.env.example` para `.env` e ajuste as variáveis conforme necessário.

3. **Suba os serviços:**
   ```bash
   docker-compose up --build
   ```
   Isso irá subir Redis, RedisGears, PostgreSQL, API, ETL e Metabase.

4. **Acesse os serviços:**
   - API: http://localhost:8000/docs
   - Metabase: http://localhost:3000
   - PostgreSQL: localhost:5432 (usuário/senha conforme `.env`)
   - Redis: localhost:6379

## Fluxo de dados

1. **Usuário envia perguntas/respostas via API**
2. **API armazena no Redis**
3. **RedisGears pode acionar eventos automáticos**
4. **ETL lê do Redis e popula o Data Warehouse (PostgreSQL)**
5. **Views SQL pré-criadas facilitam análises no Metabase**

## Popular dados fake

- Use os scripts em `carga-dados-fake/` para gerar e carregar perguntas e respostas de exemplo.
- Exemplo:
  ```bash
  python carga-dados-fake/gerar_dados_extendidos.py
  ```

## Rodar o ETL manualmente

- O ETL roda automaticamente via container, mas pode ser executado manualmente:
  ```bash
  docker-compose run --rm etl
  ```

## Acessar o Metabase

- Acesse [http://localhost:3000](http://localhost:3000)
- Usuário e senha padrão podem ser definidos via `.env`.
- Conecte o banco PostgreSQL e utilize as views para criar dashboards.

## Principais views SQL para análise

- Alternativas mais votadas
- Questões mais acertadas
- Ranking de alunos
- Questões com mais retentativas
- Distribuição por assunto e dificuldade

Os scripts das views estão em `sql/`.
