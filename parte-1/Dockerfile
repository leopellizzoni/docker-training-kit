# Imagem base: nginx (servidor web) sobre Alpine Linux, uma distribuição pequena.
# A versão fica fixa: "latest" muda sem aviso e a imagem deixaria de ser a mesma.
FROM nginx:1.30-alpine

# Copia a pasta sistema (o site: index.html e css/) para a pasta que o nginx publica.
# Só o site entra na imagem; o Dockerfile e o README.md ficam de fora.
COPY sistema/ /usr/share/nginx/html/

# Documenta a porta em que o nginx escuta dentro do contêiner.
EXPOSE 80
