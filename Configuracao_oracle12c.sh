####Configuracao.sh######

#/bin/bash
echo "Qual o Nome para a Maquina"
read NOME;
echo "Qual o IP para a Maquina"
read IPNOVO;
echo "Qual a GATEWAY da Maquina"
read GWNOVA;
echo "Qual o SID para a BD"
read SIDNOVO;
echo "Qual o characterSet para a BD ex: AL32UTF8 / WE8MSWIN1252 default: WE8MSWIN1252 sim? "
read CHANOVO;

if [ "$CHANOVO" = 'sim' ]; then
echo "characterSet definido foi o WE8MSWIN1252 "
CHANOVO="WE8MSWIN1252"
else
echo "characterSet definido foi o AL32UTF8 "
CHANOVO="AL32UTF8"
fi

echo "Continuar sim/nao"
read option;

HWADDRNOVO=`ifconfig -a  | grep eth | awk {'print$5'}`

case "$option" in
    sim)
        rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0
        mv /root/ifcfg-eth0 /etc/sysconfig/network-scripts/
        sed -i "s/IPDAMAQUINA/$IPNOVO/g" /etc/hosts
        sed -i "s/NOMEDAMAQUINA/$NOME/g" /etc/hosts
        sed -i "s/IPDAMAQUINA/$IPNOVO/g" /etc/sysconfig/network-scripts/ifcfg-eth0
        sed -i "s/GWDAMAQUINA/$GWNOVA/g" /etc/sysconfig/network-scripts/ifcfg-eth0
        sed -i "s/HWADDRNOVO/$HWADDRNOVO/g" /etc/sysconfig/network-scripts/ifcfg-eth0
        sed -i "s/NOMEDAMAQUINA/$NOME/g" /etc/sysconfig/network
        sed -i "s/GWDAMAQUINA/$GWNOVA/g" /etc/sysconfig/network
        hostname $NOME
        /etc/init.d/network restart
        echo "###########################"
        echo "###########################"
        echo "A configurar o CRS"
        /u01/app/12.1.0.2/grid/perl/bin/perl -I/u01/app/12.1.0.2/grid/perl/lib -I/u01/app/12.1.0.2/grid/crs/install /u01/app/12.1.0.2/grid/crs/install/roothas.pl

        echo "###########################"
        echo "###########################"
        echo "A criar a particao no disco"
        echo -e 'p\nn\np\n1\n1\n\nw' | fdisk /dev/sdb

        echo "###########################"
        echo "###########################"
        echo "A criar o disco DISK01"
        /etc/init.d/oracleasm createdisk DISK01 /dev/sdb1

        echo "###########################"
        echo "###########################"
        echo "A configurar o ASM"
        su - grid -c "asmca -silent -configureASM  -sysAsmPassword manager123 -asmsnmpPassword manager123 -diskString 'ORCL:*' -diskGroupName DG0 -disk 'ORCL:*' -redundancy EXTERNAL"

        echo "###########################"
        echo "###########################"
        echo "A configurar o orapw+ASM"
        su - grid -c "orapwd file=/u01/app/12.1.0.2/grid/dbs/orapw+ASM password=manager123"

        echo "###########################"
        echo "###########################"
        echo "A configurar o LISTENER"
        cp /root/ListenerConfig.rsp /tmp/ListenerConfig.rsp;
        su - grid -c "/u01/app/12.1.0.2/grid/bin/netca -silent -responsefile /tmp/ListenerConfig.rsp"
        rm -rf /tmp/ListenerConfig.rsp

        echo "###########################"
        echo "###########################"
        echo "A Criar a BD ORACLE"
        su - oracle -c "dbca -silent -createDatabase -templateName IEStemplateBD12C.dbc -gdbname $SIDNOVO -sid $SIDNOVO -characterSet $CHANOVO -sysPassword manager123 -systemPassword manager123 -storageType ASM -diskGroupName DG0 -listeners LISTENER"

        echo "###########################"
        echo "###########################"
        echo "Alterar as permissoes no tnsnames.ora"
#       chmod o+r /u01/app/oracle/product/12.1.0.2/db_1/network/admin/tnsnames.ora

        echo "###########################"
        echo "###########################"
        echo "Alterar o SID no profile.d/oracle.sh"
#       sed -i "s/SIDDB/$SIDNOVO/g" /etc/profile.d/oracle.sh

        echo "###########################"
        echo "###########################"
        echo "Alterar o SID no user oracle bashrc"
#       sed -i 's/#ORACLE/ORACLE/g' /home/oracle/.bashrc
#       sed -i "s/SIDBD/$SIDNOVO/g" /home/oracle/.bashrc

        echo "BD Criada e Configurada"
        ;;
    nao)
        exit
        ;;
esac