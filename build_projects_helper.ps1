# This script helps creating project files for protobuf.  The argument is the path of Google\protobuf.
# It produces one pair of *.vcxproj, *.vcxproj.filters files for each project.  The generated
# XML may just be inserted at the right place in the project files, replacing whatever was there.
# TODO(phl): The next time we do this dance, find a way to automatically insert the text generated here
# in the project files.  Copying by hand is tedious and error-prone.  Also, use functions in the scripts
# for the other solutions.

$dir = resolve-path $args[0]
$testheaderspattern = @("fake_*.h", "mock_*.h", "test_*.h", "*test_util*.h", "*_test.h", "*_tester.h", "*unittest.h")
$testsourcespattern = @("fake_*.c*", "mock_*.c*", "test_*.c*", "*test_util*.c*", "*_test.c*", "*_tester.c*", "*unittest.c*")
$benchmarkheaderspattern = @("*_benchmark.h")
$benchmarksourcespattern = @("*_benchmark.c*")
$exclusionpattern = $testheaderspattern + $testsourcespattern + $benchmarkheaderspattern + $benchmarksourcespattern
$protopattern = @("*.pb.h", "*.pb.cc")
# See generate_descriptor_proto.sh for these lists.
$runtimeprotoheaderspattern = @("any.pb.h", `
                                "api.pb.h", `
                                "cpp_features.pb.h", `
                                "descriptor.pb.h", `
                                "duration.pb.h", `
                                "empty.pb.h", `
                                "field_mark.pb.h", `
                                "source_context.pb.h", `
                                "struct.pb.h", `
                                "timestamp.pb.h", `
                                "type.pb.h", `
                                "wrapper.pb.h")
$runtimeprotosourcespattern = @("any.pb.cc", `
                                "api.pb.cc", `
                                "cpp_features.pb.cc", `
                                "descriptor.pb.cc", `
                                "duration.pb.cc", `
                                "empty.pb.cc", `
                                "field_mark.pb.cc", `
                                "source_context.pb.cc", `
                                "struct.pb.cc", `
                                "timestamp.pb.cc", `
                                "type.pb.cc", `
                                "wrapper.pb.cc")
$compilerprotoheaderspattern = @("plugin.pb.h")
$compilerprotosourcespattern = @("plugin.pb.cc")

function Generate-Header {
  param (
    [string]$RelativePath,
    [ref]$Filters,
    [ref]$Vcxproj
  )
  $Filters.Value +=
      "    <ClInclude Include=`"$RelativePath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $Vcxproj.Value +=
      "    <ClInclude Include=`"$RelativePath`" />`r`n"
}

function Generate-InternalHeader {
  param (
    [string]$RelativePath,
    [ref]$Filters,
    [ref]$Vcxproj
  )
  $Filters.Value +=
      "    <ClInclude Include=`"$RelativePath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $Vcxproj.Value +=
      "    <ClInclude Include=`"$RelativePath`" />`r`n"
}

function Generate-InternalSource {
  param (
    [string]$RelativePath,
    [ref]$Filters,
    [ref]$Vcxproj
  )
  $Filters.Value +=
      "    <ClCompile Include=`"$RelativePath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $Vcxproj.Value +=
      "    <ClCompile Include=`"$RelativePath`" />`r`n"
}

function Generate-Proto {
  param (
    [string]$RelativePath,
    [string]$ProtoPath,
    [ref]$Filters,
    [ref]$Vcxproj
  )
  $relativepbhpath = $RelativePath -replace "\.proto", ".pb.h"
  $relativepbccpath = $RelativePath -replace "\.proto", ".pb.cc"
  $Filters.Value +=
      "     <CustomBuild Include=`"$RelativePath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $Filters.Value +=
      "    <ClInclude Include=`"$relativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $Filters.Value +=
      "    <ClCompile Include=`"$relativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $Vcxproj.Value +=
      "    <CustomBuild Include=`"$RelativePath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=$ProtoPath -I..\.. -I..\..\src --cpp_out=$ProtoPath `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $Vcxproj.Value +=
      "    <ClInclude Include=`"$relativepbhpath`" />`r`n"
  $Vcxproj.Value +=
      "    <ClCompile Include=`"$relativepbccpath`" />`r`n"
}

function Generate-Source {
  param (
    [string]$RelativePath,
    [ref]$Filters,
    [ref]$Vcxproj
  )
  $Filters.Value +=
      "    <ClCompile Include=`"$RelativePath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $Vcxproj.Value +=
      "    <ClCompile Include=`"$RelativePath`" />`r`n"
}

$filtersheaders = "  <ItemGroup>`r`n"
$vcxprojheaders = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include "*.h" -Exclude $exclusionpattern |`
Where-Object {$_.Name -like $runtimeprotoheaderspattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filtersheaders) -Vcxproj ([ref]$vcxprojheaders)
}
$filtersheaders += "  </ItemGroup>`r`n"
$vcxprojheaders += "  </ItemGroup>`r`n"

$filtersinternal = "  <ItemGroup>`r`n"
$vcxprojinternal = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\third_party\utf8_range\*" -Include *.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\third_party\\", "..\..\third_party\"
  Generate-InternalHeader -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\third_party\utf8_range\*" -Include *.c -Exclude main.c | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\third_party\\", "..\..\third_party\"
  Generate-InternalSource -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-InternalHeader -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-InternalSource -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-InternalHeader -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-InternalSource -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-InternalHeader -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-InternalSource -RelativePath $msvcrelativepath -Filters ([ref]$filtersinternal) -Vcxproj ([ref]$vcxprojinternal)
}
$filtersinternal += "  </ItemGroup>`r`n"
$vcxprojinternal += "  </ItemGroup>`r`n"

$filterssources = "  <ItemGroup>`r`n"
$vcxprojsources = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include *.cc -Exclude $exclusionpattern | `
Where-Object {$_.Name -like $runtimeprotosourcespattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterssources) -Vcxproj ([ref]$vcxprojsources)
}
$filterssources += "  </ItemGroup>`r`n"
$vcxprojsources += "  </ItemGroup>`r`n"

$filtersprotoc = "  <ItemGroup>`r`n"
$vcxprojprotoc = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include *.h -Exclude $exclusionpattern | `
Where-Object {$_.Name -like $compilerprotoheaderspattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotoc) -Vcxproj ([ref]$vcxprojprotoc)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include *.cc ` -Exclude (@("main*.cc") + $exclusionpattern) | `
Where-Object {$_.Name -like $compilerprotosourcespattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotoc) -Vcxproj ([ref]$vcxprojprotoc)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotoc) -Vcxproj ([ref]$vcxprojprotoc)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include *.cc -Exclude (@("main*.cc") + $exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotoc) -Vcxproj ([ref]$vcxprojprotoc)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\field_generators\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotoc) -Vcxproj ([ref]$vcxprojprotoc)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\field_generators\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotoc) -Vcxproj ([ref]$vcxprojprotoc)
}
$filtersprotoc += "  </ItemGroup>`r`n"
$vcxprojprotoc += "  </ItemGroup>`r`n"

$filtersprotocmain = "  <ItemGroup>`r`n"
$vcxprojprotocmain = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include main.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filtersprotocmain) -Vcxproj ([ref]$vcxprojprotocmain)
}
$filtersprotocmain += "  </ItemGroup>`r`n"
$vcxprojprotocmain += "  </ItemGroup>`r`n"

$filterstests = "  <ItemGroup>`r`n"
$vcxprojtests = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include $testheaderspattern -Exclude $protopattern  | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\editions\*" -Include $testheaderspattern -Exclude $protopattern  | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\editions\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\testing\*" -Include *.h -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\testing\*" -Include *.cc -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\*" -Include *test*.proto `
  -Exclude unittest_custom_options_unlinked.proto,unittest_legacy_features.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Proto -RelativePath $msvcrelativepath -ProtoPath ..\..\src -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include test*.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Proto -RelativePath $msvcrelativepath -ProtoPath ..\..\src -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\test_protos\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Proto -RelativePath $msvcrelativepath -ProtoPath ..\..\src -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Proto -RelativePath $msvcrelativepath -ProtoPath ..\..\src -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\editions\golden\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  Generate-Proto -RelativePath $msvcrelativepath -ProtoPath ..\.. -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
Get-ChildItem "$dir\editions\input\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  Generate-Proto -RelativePath $msvcrelativepath -ProtoPath ..\.. -Filters ([ref]$filterstests) -Vcxproj ([ref]$vcxprojtests)
}
$filterstests += "  </ItemGroup>`r`n"
$vcxprojtests += "  </ItemGroup>`r`n"

$filtersbenchmarks = "  <ItemGroup>`r`n"
$vcxprojbenchmarks = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include $benchmarkheaderspattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Header -RelativePath $msvcrelativepath -Filters ([ref]$filtersbenchmarks) -Vcxproj ([ref]$vcxprojbenchmarks)
}
Get-ChildItem "$dir\src\google\protobuf\*" -Include $benchmarksourcespattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  Generate-Source -RelativePath $msvcrelativepath -Filters ([ref]$filtersbenchmarks) -Vcxproj ([ref]$vcxprojbenchmarks)
}
$filtersbenchmarks += "  </ItemGroup>`r`n"
$vcxprojbenchmarks += "  </ItemGroup>`r`n"

$dirfilterspath = [string]::format("{0}/protobuf_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $dirfilterspath,
    $filtersheaders + $filtersinternal + $filterssources,
    [system.text.encoding]::utf8)

$protocfilterspath = [string]::format("{0}/protoc_lib_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $protocfilterspath,
    $filtersprotoc,
    [system.text.encoding]::utf8)

$protocmainfilterspath = [string]::format("{0}/protoc_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $protocmainfilterspath,
    $filtersprotocmain,
    [system.text.encoding]::utf8)

$testsfilterspath = [string]::format("{0}/tests_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $testsfilterspath,
    $filterstests,
    [system.text.encoding]::utf8)

$benchmarksfilterspath = [string]::format("{0}/benchmarks_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $benchmarksfilterspath,
    $filtersbenchmarks,
    [system.text.encoding]::utf8)

$dirvcxprojpath = [string]::format("{0}/protobuf_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $dirvcxprojpath,
    $vcxprojheaders + $vcxprojinternal + $vcxprojsources,
    [system.text.encoding]::utf8)

$protocvcxprojpath = [string]::format("{0}/protoc_lib_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $protocvcxprojpath,
    $vcxprojprotoc,
    [system.text.encoding]::utf8)

$protocmainvcxprojpath = [string]::format("{0}/protoc_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $protocmainvcxprojpath,
    $vcxprojprotocmain,
    [system.text.encoding]::utf8)

$testsvcxprojpath = [string]::format("{0}/tests_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $testsvcxprojpath,
    $vcxprojtests,
    [system.text.encoding]::utf8)

$benchmarksvcxprojpath = [string]::format("{0}/benchmarks_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $benchmarksvcxprojpath,
    $vcxprojbenchmarks,
    [system.text.encoding]::utf8)
