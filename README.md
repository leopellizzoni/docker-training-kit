# Prática de contêineres com Docker

Prática de virtualização com contêineres: (1) do Dockerfile a um site em execução e (2) dois sites com um balanceador de carga (load balancer). Tudo roda no seu computador com o Docker. Os sites são páginas HTML estáticas hospedadas pelo nginx.

## Antes de começar

1. Instale e abra o [Docker Desktop](https://www.docker.com/products/docker-desktop/). Aguarde o status "Engine running". No Linux, você também pode usar o Docker Engine com o plugin do Compose.
2. Abra um terminal (PowerShell no Windows, Terminal no macOS e no Linux) e confirme que os dois comandos abaixo funcionam sem erro:

   ```
   docker version
   docker compose version
   ```

3. Clone este repositório (ou baixe o ZIP pelo botão **Code** do GitHub) e abra o terminal na pasta dele.

## Partes da prática

| Parte | O que você vai fazer |
|---|---|
| [1. Do Dockerfile ao contêiner](parte-1/README.md) | Construir uma imagem a partir de um Dockerfile, executar um contêiner e publicar uma porta. Verificar por que alterar um arquivo no computador não altera o site que já está em execução. |
| [2. Dois sites com balanceador de carga](parte-2/README.md) | Iniciar dois sites e um balanceador com o Docker Compose. Parar cada contêiner, observar o que continua funcionando e identificar o ponto único de falha. |

## Como fazer cada parte

1. Faça as partes na ordem. Todas usam a porta 8084, por isso remova os contêineres de uma parte antes de começar a próxima.
2. Entre na pasta da parte (por exemplo, `cd parte-1`) e execute os comandos de dentro dela. O `docker build` e o `docker compose` procuram os arquivos na pasta atual do terminal.
3. Siga o enunciado, que é o `README.md` de cada pasta.

## Estrutura do repositório

Cada parte é uma pasta independente. O site fica sempre na subpasta `sistema/`, separado dos arquivos que configuram os contêineres.

```
parte-1/
├── README.md            enunciado: passos, previsões e perguntas
├── resposta.md          resultado esperado, respostas e erros comuns
├── Dockerfile           instruções para construir a imagem
└── sistema/             o site: index.html e css/

parte-2/
├── README.md
├── resposta.md
├── docker-compose.yml   definição dos contêineres e da rede
├── Dockerfile.site      instruções para construir as imagens dos sites
├── sistema/             os dois sites: site1/ e site2/
├── balanceador/         configuração do nginx que distribui as requisições
└── cliente/             script que conta qual site respondeu
```

## Como funciona

Por amor à simplicidade o sistema é representado pelo arquivo index.html e é hospedado pelo nginx. 

**Parte 1.** O `Dockerfile` usa a imagem do nginx como base e copia a pasta `sistema/` para dentro dela. O `docker run` cria um contêiner a partir dessa imagem e liga a porta 8084 do computador à porta 80 do contêiner.

```
navegador ──> localhost:8084 ──> contêiner (nginx + sistema/)
```

**Parte 2.** O Docker Compose cria três contêineres em uma rede interna, na qual cada contêiner encontra os outros pelo nome do serviço. O balanceador, que é outro nginx, recebe as requisições na porta 8084 e as distribui alternadamente entre `site1` e `site2`. O serviço `cliente` faz várias requisições seguidas e conta qual site respondeu a cada uma.

```
navegador ──> balanceador (8084) ──┬──> site1  (acesso direto: 8085)
                                   └──> site2  (acesso direto: 8086)
```


## Respostas

O `resposta.md` de cada parte traz o resultado esperado de cada passo e considerações sobre o teste prático.

- IDs, endereços IP e tempos variam de um computador para outro. O formato do resultado é o mesmo.
- Uma resposta escrita com outras palavras está correta se explicar a causa.
- Se o seu resultado foi diferente do esperado, consulte a tabela de erros comuns.