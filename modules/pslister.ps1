function run 
{
	ps | Where-Object { $_.cpu -gt 100 }
}