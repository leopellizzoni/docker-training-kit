# Resposta da Parte 1: Do Dockerfile ao contêiner

Compare com as suas anotações depois de terminar o [enunciado](README.md).

## Resultado esperado

| Passo | Resultado |
|---|---|
| 1. Construir a imagem | O `docker image ls meu-site` lista a imagem `meu-site` com a tag `1.0`. |
| 2. Executar o contêiner | O `docker ps` mostra o contêiner `site-v1` com a porta `0.0.0.0:8084->80/tcp`. O navegador mostra "Hello World!". Cada recarga da página gera no `docker logs site-v1` uma linha `"GET / HTTP/1.1" 200`, além das linhas do CSS. |
| 3. Alterar o site | Depois de salvar o `sistema/index.html`, a porta 8084 continua mostrando "Hello World!". Depois do build da versão 1.1, a porta 8084 mostra "Hello World!" e a porta 8085 mostra "Olá, \<seu nome\>!". O `docker image ls meu-site` lista as tags `1.0` e `1.1`. |
| 4. Provocar um conflito de porta | O Docker retorna `Bind for 0.0.0.0:8084 failed: port is already allocated`. O `docker ps -a` mostra o `site-v3` com o status `Created`. Depois de `docker stop site-v1`, `docker rm site-v3` e um novo `docker run`, a porta 8084 mostra "Olá, \<seu nome\>!". |
| 5. Remover uma imagem em uso | O Docker recusa e retorna `conflict: unable to delete meu-site:1.0 (must be forced) - container ... is using its referenced image ...`. |
| 6. Remover os contêineres | O `docker ps -a` não lista nenhum contêiner `site-v`. |

## Respostas às perguntas

**1. Por que a alteração no `sistema/index.html` não apareceu em http://localhost:8084?**

A instrução `COPY` do Dockerfile copia o `index.html` para dentro da imagem no momento do `docker build`. O contêiner `site-v1` foi criado a partir da imagem `1.0` e não lê os arquivos da sua pasta. Para a alteração aparecer, é preciso construir uma nova imagem e criar um contêiner a partir dela.

**2. Quantas imagens e quantos contêineres existem ao fim do passo 3? Qual é a diferença entre imagem e contêiner?**

Existem duas imagens (`meu-site:1.0` e `meu-site:1.1`) e dois contêineres em execução (`site-v1` e `site-v2`). A imagem é um pacote somente leitura com tudo o que o site precisa: a base Alpine Linux, o nginx e os arquivos do site. O contêiner é um processo em execução criado a partir de uma imagem, com uma camada própria onde pode gravar arquivos. Uma mesma imagem pode dar origem a vários contêineres.

**3. Em `-p 8084:80`, qual é a porta do computador e qual é a do contêiner? Por que dois contêineres podem usar a porta 80, mas não a mesma porta 8084?**

A porta 8084 é a do computador, e a 80 é a do contêiner. Cada contêiner tem a própria interface de rede, então a porta 80 de um contêiner não conflita com a porta 80 de outro. A porta 8084 do computador é única e só pode estar ligada a um contêiner por vez.

**4. Por que o Docker não removeu a imagem `meu-site:1.0` no passo 5?**

Porque o contêiner `site-v1` foi criado a partir dela e ainda existia, mesmo parado. O Docker só remove uma imagem quando nenhum contêiner depende dela. A ordem correta é remover primeiro o contêiner (`docker rm site-v1`) e depois a imagem (`docker rmi meu-site:1.0`). Remover um contêiner não remove a imagem.

## Erros comuns

| Mensagem ou sintoma | Causa | Solução |
|---|---|---|
| `port is already allocated` | Outro contêiner ou programa usa a porta. | Veja qual contêiner usa a porta com `docker ps` e remova com `docker rm -f <nome>`, ou use outra porta. |
| `Conflict. The container name "/site-v3" is already in use` | Já existe um contêiner com esse nome, parado ou apenas criado. | Confira com `docker ps -a`, remova com `docker rm site-v3` e execute o `docker run` de novo. |
| A página não abre depois de `docker start site-v3` | O contêiner criado durante o erro de porta não tem a porta publicada: o `docker ps` mostra `80/tcp`, sem `0.0.0.0:8084->`. | Remova o contêiner e crie de novo com `docker run`. |
| `'docker buildx build' requires 1 argument` | Falta o `.` no fim do `docker build`. | Execute `docker build -t meu-site:1.0 .` |
| `failed to read dockerfile: open Dockerfile: no such file or directory` | O comando foi executado fora da pasta `parte-1`. | Execute `cd parte-1` e repita o comando. |
| `Cannot connect to the Docker daemon` ou `error during connect` | O Docker Desktop não está aberto. | Abra o Docker Desktop e aguarde o status "Engine running". |
| `toomanyrequests` durante o build | O Docker Hub limita downloads anônimos por endereço IP, e em um laboratório todos os computadores saem pelo mesmo IP. | Execute `docker login` com uma conta gratuita do Docker Hub. |
| `favicon.ico ... failed (2: No such file or directory)` no `docker logs` | O navegador pede um ícone que o site não tem. | Nenhuma ação necessária. A mensagem pode ser ignorada. |
