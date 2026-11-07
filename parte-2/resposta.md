# Resposta da Parte 2: Dois sites com balanceador de carga

Compare com as suas anotações depois de terminar o [enunciado](README.md).

## Resultado esperado

| Passo | Resultado |
|---|---|
| 1. Iniciar os contêineres | O `docker compose ps` lista `parte-2-balanceador-1`, `parte-2-site1-1` e `parte-2-site2-1`, todos com status `Up`. A porta 8085 mostra o Site 1 (etiqueta azul), a porta 8086 mostra o Site 2 (etiqueta cinza) e a porta 8084 mostra um dos dois. |
| 2. Verificar a distribuição das requisições | No navegador, cada recarga tende a mostrar sempre o mesmo site. O cliente conta `5 Hello World - Site 1` e `5 Hello World - Site 2` com 10 requisições, e 15 e 15 com 30. Na aba Rede, a requisição da página e a do `bootstrap.min.css` têm valores diferentes no cabeçalho `X-Atendido-Por`. |
| 3. Parar um site | O cliente conta `10 Hello World - Site 2`. Uma das requisições pode levar cerca de 1 segundo e, às vezes, uma aparece como `FALHOU` no instante em que o site para. A porta 8084 continua respondendo, sempre com o Site 2. A porta 8085 não responde: o navegador informa que não conseguiu se conectar. Depois do `docker compose start site1`, a contagem volta a 5 e 5. |
| 4. Parar os dois sites | O cliente conta `4 FALHOU`. O navegador mostra `502 Bad Gateway`, com `nginx` no rodapé. Logo após a parada, pode aparecer `504 Gateway Time-out`. |
| 5. Parar o balanceador | O cliente conta `3 FALHOU`. A porta 8084 não responde, e as portas 8085 e 8086 continuam respondendo. |

## Respostas às perguntas

**1. Por que a contagem do navegador foi diferente da contagem do cliente?**

Para exibir a página, o navegador faz pelo menos duas requisições: uma para o HTML e outra para o `bootstrap.min.css`. Às vezes faz também uma terceira, para o `favicon.ico`. O balanceador alterna o site a cada requisição, e não a cada página. Com dois sites e duas requisições por página, o HTML vai sempre para o mesmo site e o CSS vai para o outro. O cliente pede apenas o HTML, por isso mostra a alternância real.

**2. Como o balanceador percebeu que o `site1` não estava disponível, e quanto tempo isso custou?**

O balanceador envia a requisição ao `site1`, a conexão não se completa e, depois de 1 segundo (`proxy_connect_timeout 1s`), ele desiste e reenvia a requisição ao `site2` (`proxy_next_upstream`). Em até 2 segundos, o DNS interno do Docker deixa de resolver o nome `site1` (`resolver ... valid=2s`), e o balanceador para de enviar requisições a ele. O custo é uma requisição cerca de 1 segundo mais lenta. Sem essas configurações, o nginx espera até 60 segundos antes de tentar o outro site.

**3. Qual erro o navegador mostrou com os dois sites parados, e qual contêiner gerou a página de erro?**

O erro é `502 Bad Gateway`, e a página foi gerada pelo próprio balanceador. Ele estava em execução e recebeu a requisição, mas não tinha nenhum site disponível para repassá-la. O "gateway" da mensagem é o balanceador.

**4. Qual contêiner é o ponto único de falha, e o que seria necessário para eliminá-lo?**

O balanceador. Com ele parado, nada responde na porta 8084, mesmo com os dois sites em execução. Para eliminar esse ponto único de falha, seriam necessários dois balanceadores e um mecanismo que direcione o cliente para o que estiver disponível. Exemplos: um endereço IP virtual que passa de um balanceador para o outro em caso de falha, ou um balanceador gerenciado de um provedor de nuvem.

**5. As portas 8085 e 8086 são necessárias para o balanceador funcionar?**

Não. O balanceador se comunica com os sites pela rede interna do Compose, na porta 80 de cada contêiner (`site1:80` e `site2:80`). As portas 8085 e 8086 servem apenas para acessar cada site diretamente pelo navegador. Sem elas, o sistema funciona da mesma forma, e os sites ficam acessíveis somente pelo balanceador, que é a configuração usual em produção.

## Erros comuns

| Mensagem ou sintoma | Causa | Solução |
|---|---|---|
| `Bind for 0.0.0.0:8084 failed: port is already allocated` no `docker compose up` | Um contêiner da Parte 1 ainda está em execução. | Veja qual com `docker ps` e remova com `docker rm -f <nome>`. |
| `no configuration file provided: not found` | O comando foi executado fora da pasta `parte-2`. | Execute `cd parte-2` e repita o comando. |
| O navegador mostra sempre o mesmo site | Comportamento esperado, explicado na resposta 1. | Use o cliente para contar as respostas. |
| A alteração em uma página não aparece | O `docker compose up` foi executado sem a opção `--build`, que reconstrói as imagens dos sites. | Execute `docker compose up -d --build`. |
| O cliente retorna `syntax error: unexpected word (expecting "do")` | O `conta.sh` foi salvo com a quebra de linha do Windows (CRLF). | Baixe o arquivo de novo do repositório ou salve-o com quebra de linha LF. |
| A porta 8084 parou de responder depois de `docker compose stop site1` | O balanceador foi parado por engano. | Confira com `docker compose ps -a` e execute `docker compose start balanceador`. |
