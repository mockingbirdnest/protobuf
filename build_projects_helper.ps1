# This script helps creating project files for protobuf.  The argument is the path of Google\protobuf.
# It produces one pair of *.vcxproj, *.vcxproj.filters files for each project.  The generated
# XML may just be inserted at the right place in the project files, replacing whatever was there.

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

$filtersheaders = "  <ItemGroup>`r`n"
$vcxprojheaders = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include "*.h" -Exclude $exclusionpattern |`
Where-Object {$_.Name -like $runtimeprotoheaderspattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersheaders +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojheaders +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
$filtersheaders += "  </ItemGroup>`r`n"
$vcxprojheaders += "  </ItemGroup>`r`n"

$filtersinternal = "  <ItemGroup>`r`n"
$vcxprojinternal = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\third_party\utf8_range\*" -Include *.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\third_party\\", "..\..\third_party\"
  $filtersinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\third_party\utf8_range\*" -Include *.c -Exclude main.c | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\third_party\\", "..\..\third_party\"
  $filtersinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternal +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojinternal +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filtersinternal += "  </ItemGroup>`r`n"
$vcxprojinternal += "  </ItemGroup>`r`n"

$filterssources = "  <ItemGroup>`r`n"
$vcxprojsources = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include *.cc -Exclude $exclusionpattern | `
Where-Object {$_.Name -like $runtimeprotosourcespattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterssources +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojsources +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterssources += "  </ItemGroup>`r`n"
$vcxprojsources += "  </ItemGroup>`r`n"

$filtersprotoc = "  <ItemGroup>`r`n"
$vcxprojprotoc = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include *.h -Exclude $exclusionpattern | `
Where-Object {$_.Name -like $compilerprotoheaderspattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include *.cc ` -Exclude (@("main*.cc") + $exclusionpattern) | `
Where-Object {$_.Name -like $compilerprotosourcespattern -or $_.Name -notlike $protopattern} | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include *.cc -Exclude (@("main*.cc") + $exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\field_generators\*" -Include *.h -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\field_generators\*" -Include *.cc -Exclude ($exclusionpattern + $protopattern) | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filtersprotoc += "  </ItemGroup>`r`n"
$vcxprojprotoc += "  </ItemGroup>`r`n"

$filtersprotocmain = "  <ItemGroup>`r`n"
$vcxprojprotocmain = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include main.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotocmain +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojprotocmain +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filtersprotocmain += "  </ItemGroup>`r`n"
$vcxprojprotocmain += "  </ItemGroup>`r`n"

$filterstests = "  <ItemGroup>`r`n"
$vcxprojtests = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\io\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\stubs\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include $testheaderspattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include $testheaderspattern -Exclude $protopattern  | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\editions\*" -Include $testheaderspattern -Exclude $protopattern  | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\editions\*" -Include $testsourcespattern -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\testing\*" -Include *.h -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\testing\*" -Include *.cc -Exclude $protopattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\*" -Include *test*.proto -Exclude unittest_legacy_features.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $msvcrelativepbhpath = $msvcrelativepath -replace "\.proto", ".pb.h"
  $msvcrelativepbccpath = $msvcrelativepath -replace "\.proto", ".pb.cc"
  $filterstests +=
      "     <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=..\..\src -I..\.. -I..\..\src --cpp_out=..\..\src `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`" />`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include test*.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $msvcrelativepbhpath = $msvcrelativepath -replace "\.proto", ".pb.h"
  $msvcrelativepbccpath = $msvcrelativepath -replace "\.proto", ".pb.cc"
  $filterstests +=
      "     <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=..\..\src -I..\.. -I..\..\src --cpp_out=..\..\src `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`" />`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\test_protos\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $msvcrelativepbhpath = $msvcrelativepath -replace "\.proto", ".pb.h"
  $msvcrelativepbccpath = $msvcrelativepath -replace "\.proto", ".pb.cc"
  $filterstests +=
      "     <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=..\..\src -I..\.. -I..\..\src --cpp_out=..\..\src `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`" />`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\util\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $msvcrelativepbhpath = $msvcrelativepath -replace "\.proto", ".pb.h"
  $msvcrelativepbccpath = $msvcrelativepath -replace "\.proto", ".pb.cc"
  $filterstests +=
      "     <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=..\..\src -I..\.. -I..\..\src --cpp_out=..\..\src `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`" />`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`" />`r`n"
}
Get-ChildItem "$dir\editions\golden\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  $msvcrelativepbhpath = $msvcrelativepath -replace "\.proto", ".pb.h"
  $msvcrelativepbccpath = $msvcrelativepath -replace "\.proto", ".pb.cc"
  $filterstests +=
      "     <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=..\.. -I..\.. -I..\..\src --cpp_out=..\.. `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`" />`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`" />`r`n"
}
Get-ChildItem "$dir\editions\input\*" -Include *.proto | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\editions\\", "..\..\editions\"
  $msvcrelativepbhpath = $msvcrelativepath -replace "\.proto", ".pb.h"
  $msvcrelativepbccpath = $msvcrelativepath -replace "\.proto", ".pb.cc"
  $filterstests +=
      "     <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "        <Filter>Proto Files</Filter>`r`n" +
      "     </CustomBuild>`r`n"
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`">`r`n" +
      "       <Filter>Generated Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`">`r`n" +
      "       <Filter>Generated Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <CustomBuild Include=`"$msvcrelativepath`">`r`n" +
      "       <Command>`"`$(OutDir)protoc`" --proto_path=..\.. -I..\.. -I..\..\src --cpp_out=..\.. `"%(Identity)`"</Command>`r`n" +
      "       <Message>Generating C++ files for %(FullPath)</Message>`r`n" +
      "       <Outputs>%(RootDir)%(Directory)%(Filename).pb.h;%(RootDir)%(Directory)%(Filename).pb.cc;%(Outputs)</Outputs>`r`n" +
      "    </CustomBuild>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepbhpath`" />`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepbccpath`" />`r`n"
}
$filterstests += "  </ItemGroup>`r`n"
$vcxprojtests += "  </ItemGroup>`r`n"

$filtersbenchmarks = "  <ItemGroup>`r`n"
$vcxprojbenchmarks = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include $benchmarkheaderspattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersbenchmarks +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojbenchmarks +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\*" -Include $benchmarksourcespattern | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
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
