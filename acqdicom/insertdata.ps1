$conf = Read-Properties $PSScriptRoot\inventory.properties

$DBConn = New-Object System.Data.Odbc.OdbcConnection
$DBConn.ConnectionString = $conf.odbc

$conf.DB = $DBConn
$DBCmd = $DBConn.CreateCommand()
 
[void]$DBCmd.Parameters.Add("@CallingAE", [System.Data.Odbc.OdbcType]::string)

[void]$DBCmd.Parameters.Add("@SUID",  [System.Data.Odbc.OdbcType]::varchar, 100)
[void]$DBCmd.Parameters.Add("@SeriesUID",  [System.Data.Odbc.OdbcType]::varchar, 100)
[void]$DBCmd.Parameters.Add("@SopUID", 	 [System.Data.Odbc.OdbcType]::varchar, 100)
[void]$DBCmd.Parameters.Add("@header", 	 [System.Data.Odbc.OdbcType]::string)
[void]$DBCmd.Parameters.Add("@report", 	 [System.Data.Odbc.OdbcType]::string)
$DBCmd.CommandText = "INSERT INTO dicomdata (callingae,suid,seriesuid,sopuid,header,report) VALUES (?,?,?,?,?::JSONB,?::JSONB)"
$DBCmd.Connection.Open()
$conf.DBCmd=$DBCmd
start-dicomserver -Port $conf.port -AET $conf.aet  -Environment $conf  -onCStoreRequest {
	param($request,$file,$association,$env) 

	  import-module D:\workspace\acqdicom\getsr.psm1
 
		$header = $file | read-dicom 
		$header.Modality
	    	$header.Remove('PixelData')
		$headerJSON  = $header   | ConvertTo-JSON -depth 5
	
	 	$SRJSON = GetConceptValue $header.ContentSequence | ConvertTo-JSON -depth 10
 
		$env.DBCmd.Parameters["@CallingAE"].Value= $association.CallingAE
 
		$env.DBCmd.Parameters["@SUID"].Value = $header.StudyInstanceUID
		$env.DBCmd.Parameters["@SeriesUID"].Value = $header.SeriesInstanceUID
		$env.DBCmd.Parameters["@SopUID"].Value = $header.SOPInstanceUID
		$env.DBCmd.Parameters["@header"].Value = $headerJSON 
		$env.DBCmd.Parameters["@report"].Value =  $SRJSON 
		[void]$env.DBCmd.ExecuteNonQuery()

		[Dicom.Network.DicomStatus]::success
}

$startdate=(get-date).AddDays(-7)
$list_rules = import-csv $PSScriptRoot\retrieve_rules.csv
 
while ($startdate -lt (get-date)) {
	 
		Write-Host $startdate
		 
		$enddate=$startdate.AddMinutes(30)
		foreach ($rules in $list_rules) {
			Write-Host search-dicom -SopClassProvider $rules.SopClassProvider -AET $conf.aet -startdate $startdate -enddate $enddate -Modality $rules.Modality
	 
			$studies=search-dicom -SopClassProvider $rules.SopClassProvider -AET $conf.aet -startdate $startdate -enddate $enddate   -Modality $rules.Modality
	 
			foreach ($study in $studies) {
 
					move-dicom -Study -SopClassProvider $rules.SopClassProvider -AET $conf.aet -moveTo  $conf.aet -StudyInstanceUID $study.StudyInstanceUID 
				}
		}
		
		$startdate=$enddate
} 
