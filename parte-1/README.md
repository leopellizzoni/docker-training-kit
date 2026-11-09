# Parte 1: Do Dockerfile ao contêiner

Nesta parte, você constrói uma imagem com um site estático hospedado pelo nginx, executa um contêiner a partir dela e verifica que alterar um arquivo no computador não altera o site que já está em execução.

| Arquivo | Conteúdo |
|---|---|
| [`Dockerfile`](Dockerfile) | Instruções para construir a imagem: usa a imagem do nginx como base e copia a pasta `sistema/` para dentro dela. |
| [`sistema/`](sistema) | O site: a página [`index.html`](sistema/index.html) e a pasta `css/`, com o Bootstrap 5.3. |

Execute todos os comandos dentro desta pasta:

```
cd parte-1
```

## 1. Construir a imagem

Leia o [`Dockerfile`](Dockerfile). Em seguida, construa a imagem e confirme que ela foi criada:

```
docker build -t meu-site:1.0 .
docker image ls meu-site
```

- `-t meu-site:1.0` define o nome (`meu-site`) e a versão, chamada de tag (`1.0`), da imagem.
- O `.` no fim indica a pasta onde estão o Dockerfile e os arquivos que ele copia.

## 2. Executar o contêiner

```
docker run -d --name site-v1 -p 8084:80 meu-site:1.0
docker ps
```

- `-d` executa o contêiner em segundo plano e libera o terminal.
- `--name site-v1` define o nome do contêiner. Sem essa opção, o Docker gera um nome aleatório.
- `-p 8084:80` liga a porta 8084 do computador à porta 80 do contêiner, onde o nginx atende.
- docker image é o comando usado para listar a imagem. Deverá aparecer se foi criado com sucesso no comando anterior

Abra <http://localhost:8084> no navegador. Recarregue a página algumas vezes e veja o log do nginx. Cada linha corresponde a uma requisição:

```
docker logs site-v1
```

## 3. Alterar o site

**Previsão:** se você alterar o `sistema/index.html` agora, a página em <http://localhost:8084> muda quando você recarregar?

1. No `sistema/index.html`, troque `Hello World!` por `Olá, <seu nome>!` e salve o arquivo.
2. Recarregue <http://localhost:8084> e compare com a sua previsão.
3. Construa a versão 1.1 da imagem e execute um segundo contêiner, na porta 8085:

   ```
   docker build -t meu-site:1.1 .
   docker run -d --name site-v2 -p 8085:80 meu-site:1.1
   docker image ls meu-site
   docker ps
   ```

4. Abra <http://localhost:8084> e <http://localhost:8085> e compare as duas páginas.

## 4. Provocar um conflito de porta

Execute a versão 1.1 também na porta 8084:

```
docker run -d --name site-v3 -p 8084:80 meu-site:1.1
```

O Docker retorna um erro. Leia a mensagem e identifique qual contêiner ocupa a porta 8084. Em seguida, pare o `site-v1` com `docker stop site-v1` e faça a versão 1.1 responder em <http://localhost:8084>.

O contêiner `site-v3` é criado mesmo quando o `docker run` falha (confira com `docker ps -a`). Para executar o comando de novo com o mesmo nome, remova o contêiner antes com `docker rm site-v3`. Não use `docker start site-v3`: o contêiner inicia sem a porta publicada.

## 5. Remover uma imagem em uso

O contêiner `site-v1` está parado, mas ainda existe. Tente remover a imagem a partir da qual ele foi criado:

```
docker rmi meu-site:1.0
```

Leia a mensagem de erro.

## 6. Remover os contêineres

```
docker rm -f site-v1 site-v2 site-v3
docker ps -a
```

O `docker rm -f` para e remove os contêineres em um único comando. Remova todos antes de começar a Parte 2, que também usa a porta 8084.

## Considerações

1. Por que a alteração no `sistema/index.html` não apareceu em <http://localhost:8084>?
2. Ao fim do passo 3, quantas imagens `meu-site` existem e quantos contêineres estão em execução? Qual é a diferença entre imagem e contêiner?
3. Em `-p 8084:80`, qual número é a porta do computador e qual é a porta do contêiner? Por que dois contêineres podem usar a porta 80 internamente, mas não a mesma porta 8084 do computador?
4. Por que o Docker não removeu a imagem `meu-site:1.0` no passo 5? Em que ordem é preciso remover para que funcione?

A resposta está em [`resposta.md`](resposta.md).
