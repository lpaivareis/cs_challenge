# Ruby

Para esse projeto utilizei ruby na versão `3.2.2`, caso não tenha instalado em sua maquina recomento utilizar um gerenciador de versões para facilitar o uso, recomendo o [ASDF](https://www.lucascaton.com.br/2020/02/17/instalacao-do-ruby-do-nodejs-no-ubuntu-linux-usando-asdf).

## Gems

Foram utilizado as bibliotecas:
* Byebug (Para facilitar o debbuging).
* Minitest (Obrigatoria para os testes da aplicação)
* Rubocop e Rubocop-performance (Para garantir qualidade de código)

## Instalando as bibliotecas

Para instalar as bibliotecas basta utilizar o comando abaixo.

```console
$ bundle install
```

## Como rodar os testes

No terminal, execute os comandos:

(Antes de executar o comando verifique que o console esteja no mesmo path que se encotra o arquivo).

```console
ruby customer_success_balancing.rb
```

## Rubocop.

No terminal, execute o comando abaixo para que o rubocop seja executado:

```console
bundle exec rubocop
```