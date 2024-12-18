FROM nginx:stable-bookworm
LABEL maintainer='rabinauget@gmail.com'
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install git -y && apt clean -y && rm -Rf /var/lib/apt/lists/*
RUN git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html/
RUN mv nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'