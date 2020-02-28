#Inventory script
 
 
$conf = Read-Properties $PSScriptRoot\inventory.properties
 
Set-Content -Path $conf.tempcsv 
			-Value '"CallingAE","InstitutionName","Manufacturer","ManufacturerModelName","StationName",
					"Modality","SOPClassUID","SoftwareVersions"',"DeviceSerialNumber","SpartialResolution",
					"DateofLastCalibration","TimeofLastCalibration","PixelPaddingValue"


start-dicomserver -Port $conf.port -AET $conf.aet  -Environment $conf  -onCStoreRequest {
	param($request,$file,$association,$env)

		$attribute = read-dicom -DicomFile $file
		$NewLine = '"{0}","{1}","{2}","{3}","{4}","{5}","{6}","{7}","{8}","{9}","{10}","{11}","{12}"' 
				 -f  $association.CallingAE,$attribute.InstitutionName,$attribute.Manufacturer,
					$attribute.ManufacturerModelName,$attribute.StationName,$attribute.Modality,
					$attribute.SOPClassUID,$attribute.SoftwareVersions,$attribute.DeviceSerialNumber,
					$attribute.SpatialResolution,$attribute.DateofLastCalibration,$attribute.TimeofLastCalibration,
					$attribute.PixelPaddingValue
		$NewLine | add-content -path $env.tempcsv 
		[Dicom.Network.DicomStatus]::success
}

$startdate=(get-date).AddDays(-1)

while ($startdate -lt (get-date)) {

		Write-Host $startdate

		$enddate=$startdate.AddMinutes(30)
		
		Write-Host search-dicom -SopClassProvider $conf.pacs -AET $conf.aet -startdate $startdate -enddate $enddate

		$studies=search-dicom -SopClassProvider $conf.pacs -AET $conf.aet -startdate $startdate -enddate $enddate

		foreach ($study in $studies) {

				move-dicom -Study -SopClassProvider  $conf.pacs  -AET $conf.aet -moveTo  $conf.aet -StudyInstanceUID $study.StudyInstanceUID 
			}
		$startdate=$enddate
	}	

import-csv -path $conf.tempcsv | 
		Sort-Object CallingAE,InstitutionName,Manufacturer,ManufacturerModelName,StationName,Modality,SOPClassUID,
			 SoftwareVersions,DeviceSerialNumber,SpatialResolution,DateofLastCalibration,TimeofLastCalibration -Unique  | export-csv -path $conf.outcsv
