# MAN TESTADOR
## Nome do Testador: **VALTER**
## Objetivos 
Esse testador foi idealizado para facilitar a programação de jovens computeiros da UNICAMP que estão cursando a matéria  mc102 
## Utilidade
Valter é um script para facilitar a verificação de seu programa pelos casos
teste do *SuSy*. O que não representa que o programa está correto, mas que passou
pelos casos **abertos** do *SuSy*.

## O que é feito pelo script
O script permite baixar os testes abertos do SuSy e os coloca em pastas
como IN e RES, respectivamente das entradas e das saídas esperadas.
Após isso ele compila todos os arquivos *.c que estam na mesma pasta que o
Valter, e faz a verificação com o comando "diff"  das saídas de seu programa
com as saídas esperadas.  

## Como utilizar
1. Coloque os arquivos *.c ou *.h do laboratório de teste numa pasta separada de qualquer outro tipo de arquivo;
2. Coloque o valter.sh nessa mesma pasta;
3. Verifique se o valter tem permissão para ser executado;
* Caso não possua, execute o comando : 
>			chmod +x valter.sh

4. Execute o valter com o comando:
>     ./valter.sh

+ Obs: Caso o programa demore muito para executar, seu programa pode estar em loop infinito, assim para interrompe-lo utilize:

>  ctrl+c

## Utilizando o Valter offline
* Certifique-se que as pastas IN, OUT, RES estão na mesma pasta do valter. 
* Certifique-se que na pasta IN há todas as entradas
* Certifique-se que na pasta RES há todas as saídas esperadas.
* Rode o Valter sem a opção de baixar arquivos.



### Obs:
* Instale os programas curl , gcc.
