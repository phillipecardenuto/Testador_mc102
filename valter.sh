# Scrpit: Testador para labs de mc102 
#!/bin/bash
 
#PERGUNTAS USUAIS AO USUARIO    
echo -e "\e[92mDigite o numero do lab de Hoje (com dois digitos e letra, se for o caso), i.e. (01):"
read num 
echo -e "\e[92mDigite (\e[93ms\e[92m)im para baixar os arquivos e (\e[93mn\e[92m)ao para somente testalos:"
read baixa
#Verifica se ha internet acessando o google
function Online {
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
        on=1
else
    on=0
fi
}
 
# Verifica se o Usuario possui o comando curl  instaldo
function Curlerror {
    echo "Ow, instala o comando 'curl' com o comando sudo..."
    echo "Depois nois conversa"
    exit
}
 
 
on=0
#Caso a o usuario queira baixar os Testes
if [ "$baixa" = s ]; then
    #trap eh um comando que impede que o programa capote sem que algumas
    #alteracoes sejam feitas, i.e. apagar pastas criadas pelo Testador
    trap 'rm  *.in *.res -f ; echo "NÃO ME MATE!!" ; exit' 0 1 2 3 15  
# Verifica se o Usuario possui o comando curl  instaldo
    which curl > /dev/null || Curlerror
    j=1
    k=1
    #Baixa os testes#
    arq="arq$(printf '%02d' $j)"
    echo "Baixando $(printf '%02d' $j)"
    echo
    #Comando usado para fazer o download do SuSy
    curl https://susy.ic.unicamp.br:9999/mc102ijkl/$num/dados/$arq.in --insecure -O -s 
    curl https://susy.ic.unicamp.br:9999/mc102ijkl/$num/dados/$arq.res --insecure -O -s 
    PARADA=""
    #Parada se da quando nao eh valido o arquivo baixado
    while ["$PARADA" != ""]
    do
        Online
        if [ "$on" = 0 ]; then
            echo "Putz.. Sua internet não tá boa"
            exit
        fi
        j=$[$j+1]
        arq="arq$(printf '%02d' $j)"
        curl https://susy.ic.unicamp.br:9999/mc102ijkl/$num/dados/$arq.in --insecure -O -s 
        curl https://susy.ic.unicamp.br:9999/mc102ijkl/$num/dados/$arq.res --insecure -O -s 
        PARADA=$(grep HTML $arq.in)
        if ["$PARADA" != ""]
        then
            echo "Baixando $(printf '%02d' $j)"
            echo
            if [ ! -e "$arq.in"  ]; then
                echo "Putz.. Sua internet não tá boa"
                echo "Não consigo baixar os arquivos direito...."
                echo "Tente Novamente mais tarde"
                exit
            fi
        fi
    done
    j=$[$j-1]
    rm -f $arq.in $arq.res
    baixado=0 
    trap 'rm  *.in *.res -f ; echo "NÃO ME MATE!!" ; exit'  1 2 3 15 
    #Caso o usuario nao queira baixar os Testes
else
    baixado=1
    if [  -d "TEST" ]; then
        rm -fr TEST
    fi
    mkdir TEST
    if [  -d "IN" ]; then
        cd IN
        j=$(ls -l | grep -v ^l | wc -l)
        j=$[$j-1]
        cp *.in ../TEST
        cd ../RES
        cp *.res ../TEST
        cd ..
        cp *.c TEST
        cd TEST
 
    else
        cp *.in TEST
        cp *.res TEST
        cp *.c   TEST
        cd TEST
    fi
    trap 'rm -rf ../TEST ; echo "NÃO ME MATE!!!" ; exit'   1 2 3 15 
 
fi
#Compila o 'arquivo.c'
 
#Mudar aqui o $lab no fim por *.c
gcc -std=c99 -pedantic -Wall -lm  -g *.c  
#Caso de Erro de Compilacao
if [ $? -ne 0 ] ; then
    trap 'rm -rf ../TEST ; echo "NÃO ME MATE!!!" ; exit'   1 2 3 15 
    echo -e "\e[93mERRO NA COMPILAÇÃO,ESSE \e[4mNEGOCIO\e[24m NAO COMPILA"
    echo -e "\e[93mTente Outra Vez, ainda da tempo!"
    if [ "$baixado" = 0 ] ; then
 
        mkdir OUT
        mv *.out OUT  
        mkdir IN
        mv *.in IN  
        mkdir RES
        mv *.res RES 
    fi
    if [  -d "TEST" ]; then
        rm -fr TEST
    fi
    exit
fi
clear
function echo_erro {
echo -e "\e[91m\e[4m\e[5mOs erros até o Teste $i  "
echo -e "Total de erros:$erros \e[0m"
}
function Organiza {
if [ "$baixado" = 0 ] ; then
    mkdir OUT > /dev/null 2>&1
    mv *.out OUT > /dev/null 2>&1 
    mkdir IN > /dev/null 2>&1
    mv *.in IN > /dev/null 2>&1
    mkdir RES > /dev/null 2>&1
    mv *.res RES > /dev/null 2>&1
else
    cd ..
fi
if [  -d "TEST" ]; then
    rm -fr TEST
fi
}
#Roda os Testes
 
 
echo "Executando os testes..."
erros=0
trap ' Organiza ; clear ; echo_erro  ; exit'  1 2 3 15 
for (( i=1; i<=$j; i++ )); do
    arq="arq$(printf '%02d' $i)"
    ./a.out < $arq.in > $arq.out
 
    #Compara com os arquivos da Resolucao
    cmp=$(diff $arq.res $arq.out)
    if [ "$cmp" != "" ]; then
        echo -e "\e[93m----Teste $i----"
    else
        echo -e "\e[92m----Teste $i----"
    fi
    if [ "$cmp" != "" ]; then
        echo
        echo -e "\e[93m"
        echo "========================================="
        echo "Erro encontrado com a entrada '$arq.in':"
        echo
        echo -e "\e[91m\e[4m\e[5m\tSAÍDA ESPERADA(SuSy) \t-\t-\t-\t-\t-\tSAÍDA DO SEU PROGRAMA\e[0m"
        diff -yt   $arq.res $arq.out 
        echo -e "\e[93m"
        echo "========================================="
        erros=$(($erros+1))
    fi
done
 
echo
echo -e "\e[91m\e[4m\e[5mTotal de erros lógicos:$erros \e[0m"
 
if [ "$baixado" = 1 ]
then
    cd ..
fi
#Verifica se Existe a pasta TEST
if [  -d "TEST" ]; then
    rm -fr TEST
else
    mkdir OUT > /dev/null 2>&1
    mv *.out OUT  
    mkdir IN > /dev/null 2>&1
    mv *.in IN  
    mkdir RES > /dev/null 2>&1
    mv *.res RES  
fi
echo
trap 'rm *.out -f ; exit'  1 2 3 15 
echo -e "\e[93m Deu certo??"
read resp
#Entra no site do SuSy caso o usuario responda sim
if [ "$resp" = sim ] || [ "$resp" = s ]
then
    echo -e "\e[5m\e[1m\e[96m\e[4m PARABÉNS\e[25m\e[21m\e[24m, Agora eh soh submeter!"
    echo -e "\e[92mVocê vai submeter agora??"
    read resp2
    if [ "$resp2" = sim ] || [ "$resp2" = s ]
    then
    trap 'rm nohup* -f ; exit' 0 1 2 3 15  
        nohup firefox https://susy.ic.unicamp.br:9999/mc102ijkl/$num & > /dev/null
        rm nohup.out -f
        clear
    fi
else
    echo -e "\e[93mTente Outra Vez, ainda da tempo!"
fi
exit 0
