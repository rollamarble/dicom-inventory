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
						CODE { $codemeaning = ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','').replace('-','')
								if ( -Not $retht.containsKey($codemeaning)) {
									$retht.Set_Item($codemeaning, @())
								} 
							foreach ($seq in $content.ConceptCodeSequence) {
							$retht.Set_Item($codemeaning,$retht.get_item($codemeaning) + $seq.CodeMeaning )}
							}
							 
						CONTAINER { $codemeaning = ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','').replace('-','')
										if ( -Not $retht.containsKey($codemeaning)) {
									$retht.Set_Item($codemeaning, @())
								} 
							$retht.Set_Item($codemeaning,$retht.get_item($codemeaning)+(GetConceptValue  $content.ContentSequence) )	}
							 
						DATETIME {$codemeaning = ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','').replace('-','')
							$retht.Add($codemeaning,$content.DateTime)}
						UIDREF { $codemeaning = ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','').replace('-','')
							$retht.Add($codemeaning, $content.UID)}
						TEXT { $codemeaning = ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','').replace('-','')
							$retht.Add($codemeaning, $content.TextValue)}
						NUM { $codemeaning = ($content.ConceptNameCodeSequence.CodeMeaning).replace(' ','').replace('-','')
							$retht.Add($codemeaning, $content.MeasuredValueSequence)}
						 
					}
				 
				
				

		}
						$retht   
}		
			