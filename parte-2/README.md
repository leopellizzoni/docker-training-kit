# Parte 2: Dois sites com balanceador de carga

Nesta parte, o Docker Compose inicia três contêineres: dois sites e um balanceador de carga (load balancer). O balanceador é um nginx que recebe todas as requisições na porta 8084 e as distribui entre os dois sites. Você vai parar um contêiner de cada vez e verificar o que continua funcionando.

```
navegador ──> balanceador (porta 8084) ──┬──> site1  (acesso direto: porta 8085)
                                         └──> site2  (acesso direto: porta 8086)
```

| Arquivo | Conteúdo |
|---|---|
| [`docker-compose.yml`](docker-compose.yml) | Definição dos três contêineres (serviços), das portas e da ordem de inicialização. Também define o serviço `cliente`, que só é executado quando chamado. |
| [`Dockerfile.site`](Dockerfile.site) | Instruções para construir as imagens dos dois sites, no mesmo formato do Dockerfile da Parte 1. |
| [`sistema/site1/`](sistema/site1), [`sistema/site2/`](sistema/site2) | Os dois sites. Eles diferem apenas no texto e na cor da etiqueta "Site 1" ou "Site 2". |
| [`balanceador/nginx.conf`](balanceador/nginx.conf) | Configuração do balanceador: para quais contêineres ele envia as requisições e o que faz quando um deles não responde. |
| [`cliente/conta.sh`](cliente/conta.sh) | Script que faz várias requisições ao balanceador e conta qual site respondeu a cada uma. |

Antes de começar, remova os contêineres da Parte 1, que ocupam a porta 8084:

```
docker rm -f site-v1 site-v2 site-v3
```

A mensagem `No such container` indica que o contêiner já tinha sido removido.

Execute todos os comandos dentro desta pasta:

```
cd parte-2
```

## 1. Iniciar os contêineres

```
docker compose up -d --build
docker compose ps
```

O `docker compose up` constrói as imagens dos sites, cria uma rede interna para os contêineres e inicia os três. A opção `--build` reconstrói as imagens quando algum arquivo dos sites foi alterado.

Abra os três endereços no navegador:

- <http://localhost:8085>: site1, acesso direto.
- <http://localhost:8086>: site2, acesso direto.
- <http://localhost:8084>: acesso pelo balanceador.

Leia o [`balanceador/nginx.conf`](balanceador/nginx.conf). Na rede interna do Compose, cada contêiner encontra os outros pelo nome do serviço. Por isso, o balanceador usa `site1` e `site2` como endereços, e não `localhost`.

## 2. Verificar a distribuição das requisições

**Previsão:** se você recarregar <http://localhost:8084> dez vezes, quantas vezes o Site 1 vai aparecer?

1. Recarregue a página (F5) dez vezes e conte quantas vezes aparece cada site.
2. Faça a mesma contagem com o cliente, que envia as requisições e soma as respostas de cada site. O primeiro comando faz 10 requisições; o segundo, 30:

   ```
   docker compose run --rm cliente
   docker compose run --rm cliente 30
   ```

3. Se a contagem do navegador for diferente da contagem do cliente, abra as ferramentas de desenvolvedor do navegador (F12), vá até a aba **Rede** (Network), recarregue a página e veja o cabeçalho `X-Atendido-Por` de cada requisição.

## 3. Parar um site

**Previsão:** com o `site1` parado, o que acontece em <http://localhost:8084>? E em <http://localhost:8085>?

```
docker compose stop site1
docker compose run --rm cliente
```

Abra <http://localhost:8084> e <http://localhost:8085> no navegador. Depois, inicie o `site1` de novo e repita a contagem:

```
docker compose start site1
docker compose run --rm cliente
```

## 4. Parar os dois sites

```
docker compose stop site1 site2
docker compose run --rm cliente 4
```

Abra <http://localhost:8084> e anote a mensagem de erro. Depois, inicie os dois sites de novo:

```
docker compose start site1 site2
```

## 5. Parar o balanceador

**Previsão:** com o balanceador parado, quais dos três endereços (portas 8084, 8085 e 8086) deixam de responder?

```
docker compose stop balanceador
docker compose run --rm cliente 3
```

Abra os três endereços no navegador. Depois, inicie o balanceador de novo:

```
docker compose start balanceador
```

## 6. Remover os contêineres

```
docker compose down
```

O `docker compose down` para e remove os contêineres e a rede. As imagens dos sites continuam no computador (confira com `docker image ls`).

## Perguntas

1. No passo 2, por que a contagem do navegador foi diferente da contagem do cliente? Quantas requisições o navegador faz para exibir a página uma vez?
2. Com o `site1` parado, o balanceador continuou respondendo. Como ele percebeu que o `site1` não estava disponível, e quanto tempo isso custou? Procure a resposta no `nginx.conf`.
3. Qual erro o navegador mostrou com os dois sites parados? Qual contêiner gerou essa página de erro?
4. Qual contêiner é o ponto único de falha desta arquitetura? O que seria necessário para eliminá-lo?
5. As portas 8085 e 8086 são necessárias para o balanceador funcionar? O que mudaria se você removesse as linhas `ports` dos sites no `docker-compose.yml`?

A resposta está em [`resposta.md`](resposta.md). Depois, siga para o [extra](../extra/README.md), sobre recuperação automática de contêineres.
