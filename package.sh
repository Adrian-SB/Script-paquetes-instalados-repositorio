#! \bin\sh

echo
echo "PAQUETES INSTALADOS A PARTIR DE UN REPOSITORIO EN CONCRETO"
echo
echo "----------------------------------------------"
echo "Repositorios instalados en el sistema"
echo "----------------------------------------------"

#Listado repositorios

ls -lh /var/lib/apt/lists/ | uniq > .rep1.txt		# Guardamos los repositorios en bruto

awk '{print $9}' .rep1.txt > .rep2.txt				# Selecionamos la columna deseada

rm .rep1.txt

sed -i 's/_/ /g' ".rep2.txt" 						# Separamos el nombre del repositorio en columnas

awk '{print $1}' .rep2.txt | uniq > .rep3.txt 		# Seleccionamos la primera columna con el domino del repositorio

rm .rep2.txt

cat .rep3.txt | grep '\.' > .lista.txt		 		# Quitamos los repositorios que no pertenescan a un dominio

rm .rep3.txt

nl .lista.txt | sort | uniq 						# Enumeramos los repositorios

echo "----------------------------------------------"
echo "Introduzca el número del repositorio seleccionado"
read option

maxOption=$(wc -l .lista.txt | awk '{print $1}') 	# Final del rango


if [[ $option == [1-$maxOption] ]]
	then
		repositorio=$(sed -n ${option}p .lista.txt)	#Guardamos el nombre del repositorio elegido 
		rm .lista.txt
		#Almacenamos la ruta a utilizar en el comando grep(no se puede escapar $)
		ruta=$(echo "/var/lib/apt/lists/"$repositorio"_*_Packages")
		#Listado de paquetes que pueden ser instalador mediente el repositorio.
		grep Package $ruta | awk '{print $2;}'| uniq > .paquetes.txt
		#Listado de paquetes instalados en el sistema y limpieza fichero.
		dpkg --get-selections | uniq > .paqInst.txt
		sed -i 's/install//g' ".paqInst.txt"
		sed -i 's/[[:space:]]\+//g' ".paqInst.txt"
		sed -i 's/ //g' ".paqInst.txt" 
		#Comparacion de ficheros para ver los paquetes instalados a partir de un rpeositorio
		fgrep -xf .paquetes.txt .paqInst.txt > .result.txt
		echo "----------------------------------------------"
		echo "Listado de paquetes instalados mediente el repositorio" $repositorio		
		echo "----------------------------------------------"
		cat .result.txt
		echo "----------------------------------------------"
		echo "Total paquetes disponibles en el repositorio" $respositorio ":" ; wc -l .paquetes.txt | awk '{print $1}'
		echo "----------------------------------------------"
		echo "Total paquetes instalados en el sistema: " ; wc -l .paqInst.txt | awk '{print $1}'
		echo "----------------------------------------------"
		echo "Total paquetes instalados a partir del repositorio: " ; wc -l .result.txt | awk '{print $1}'
		echo "----------------------------------------------"
		#Eliminamos los ficheros generados
		rm .paquetes.txt
		rm .paqInst.txt
		rm .result.txt
	else 
		echo "Obción NO válida, porfavor introduzca un número del 1 al" $maxOption
fi  

    
