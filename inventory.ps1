#Inventory script
# legge il file inventory.properties  nello stesso path dello script (esempio allegato).
# cerca nel pacs gli esami fatti nell'ultimo giorno e crea un csv con le seguenti informazioni degli esami trovati:
# "CallingAE","InstitutionName","Manufacturer","StationName","Modality","SOPClassUID","SoftwareVersions"
#
# Operazioni preliminari:
# install-module Dicom

# operazione prelimanare opzionale:
# register-product mia@email.it
#
# per lanciare lo script:
# . ./inventory.ps1


#Legge il file di configurazione e lo memorizza nella variabile conf
$conf = Read-Properties $PSScriptRoot\inventory.properties

#Crea un file csv vuoto con solo l'intestazione dei campi che verra' utilizzato come datastore temporaneo
Set-Content -Path $conf.tempcsv -Value '"CallingAE","InstitutionName","Manufacturer","StationName","Modality","SOPClassUID"',"SoftwareVersions"

#Avvia il dicomserver con le aet e porta lette dalla configurazione, la configurazione $conf viene passato nel environment del servizio
start-dicomserver -Port $conf.port -AET $conf.aet  -Environment $conf  -onCStoreRequest {
    #parametri ricevuti nella richiesta di CSTORE 
	#$request: richiesta dicom ricevuta
	#$file: istanza dicom ricevuta
	#$associazione: associazione dicom 
	#$env: ambiente ricevuto dallo script in questo caso corrisponde al contenuto di $conf
	param($request,$file,$association,$env) 
	
		#legge il contenuto dei metadati del filedicom ricevuto e li memorizza nella variabile $attribute
		$attribute = read-dicom -DicomFile $file
		#si crea una linea di testo con le informazioni estratte dalla associazione e dal file dicom
		$NewLine = '"{0}","{1}","{2}","{3}","{4}","{5}","{6}"' -f $association.CallingAE,$attribute.InstitutionName,$attribute.Manufacturer,$attribute.StationName,$attribute.Modality,$attribute.SOPClassUID,$attribute.SoftwareVersions
		#si aggiunge la linea al file csv temporaneo
		$NewLine | add-content -path $env.tempcsv 
		[Dicom.Network.DicomStatus]::success
}

#si prende il giorno precedente come datatime iniziale
$startdate=(get-date).AddDays(-1)
#si cicla fino a che non si arriva ad oggi
while ($startdate -lt (get-date)) {
		#stampo la data iniziale 
		Write-Host $startdate
		#creo la datatime finale  aggiungendo 30 minuti alla data iniziale
		$enddate=$startdate.AddMinutes(30)
		
		Write-Host search-dicom -SopClassProvider $conf.pacs -AET $conf.aet -startdate $startdate -enddate $enddate
		#ottengo gli studi fatti tra la datatime iniziale e datatime finale
		$studies=search-dicom -SopClassProvider $conf.pacs -AET $conf.aet -startdate $startdate -enddate $enddate
		#per ogni studio trovato
		foreach ($study in $studies) {
				#faccio la move verso il dicomserver instanziato dallo script
				move-dicom -Study -SopClassProvider  $conf.pacs  -AET $conf.aet -moveTo  $conf.aet -StudyInstanceUID $study.StudyInstanceUID
			}
		
		$startdate=$enddate
	}	
#una volta completata la scansione ordino ed elimino i duplicati contenuti nel file csv temporaneo e li salvo nel cvs finale	
import-csv -path $conf.tempcsv | sort CallingAE,InstitutionName,Manufacturer,StationName,Modality,SOPClassUID -Unique  | export-csv -path $conf.outcsv
