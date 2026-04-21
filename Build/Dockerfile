FROM ollama/ollama:latest

RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

COPY Volume / 

EXPOSE 80 11434
CMD ["/System/Start.sh"]