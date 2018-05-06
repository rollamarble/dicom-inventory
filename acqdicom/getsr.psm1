	function ConvertTo-PsCustomObjectFromHashtable {
     param (
         [Parameter( 
             Position = 0,  
             Mandatory = $true,  
             ValueFromPipeline = $true, 
             ValueFromPipelineByPropertyName = $true 
         )] [object[]]$hashtable
     );
    
     begin { $i = 0; }
    
     process {
         foreach ($myHashtable in $hashtable) {
             if ($myHashtable.GetType().Name -eq 'hashtable') {
                 $output = New-Object -TypeName PsObject;
                 Add-Member -InputObject $output -MemberType ScriptMethod -Name AddNote -Value { 
                     Add-Member -InputObject $this -MemberType NoteProperty -Name $args[0] -Value $args[1];
                 };
                 $myHashtable.Keys | Sort-Object | % { 
                     $output.AddNote($_, $myHashtable.$_); 
                 }
                 $output;
             } else {
                 Write-Warning "Index $i is not of type [hashtable]";
             }
             $i += 1; 
         }
     }
}

		Function GetConceptValue {
			param ( $contents ) 
				$retht= @{}
				foreach ( $content in $contents)  {
					switch ($content.ValueType) {
						CODE { 
							$retht.Set_Item(($content.ConceptNameCodeSequence.CodeMeaning).replace(' ',''), (GetConceptValue  $content.ContentSequence) )	}
						CONTAINER { 
							$retht.Set_Item(($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','') , (GetConceptValue  $content.ContentSequence) )}
						DATETIME {
							$retht.Add(($content.ConceptNameCodeSequence.CodeMeaning).replace(' ',''),$content.DateTime)}
						UIDREF {
							$retht.Add(($content.ConceptNameCodeSequence.CodeMeaning).replace(' ',''), $content.UID)}
						TEXT {
							$retht.Add(($content.ConceptNameCodeSequence.CodeMeaning).replace(' ',''), $content.TextValue)}
						NUM {
							$retht.Add( ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ',''), $content.MeasuredValueSequence)}
					}
				}
				$retht   
		}			
			