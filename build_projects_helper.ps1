# This script helps creating project files for protobuf.  The argument is the path of Google\protobuf.
# It produces one pair of *.vcxproj, *.vcxproj.filters files for each project.  The generated
# XML may just be inserted at the right place in the project files, replacing whatever was there.

$dir = resolve-path $args[0]

$filtersheaders = "  <ItemGroup>`r`n"
$vcxprojheaders = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include *.h -Exclude test_*.h,*test_util*.h,*_tester.h,*unittest.h | `
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
$filtersinternal += "  </ItemGroup>`r`n"
$vcxprojinternal += "  </ItemGroup>`r`n"

$filterssources = "  <ItemGroup>`r`n"
$vcxprojsources = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\src\google\protobuf\*" -Include *.cc  -Exclude *test_util*.cc,*_test.cc,*_benchmark.cc,*_tester.cc,*unittest.cc | `
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
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include *.h `
  -Exclude main*.cc,fake_*.*,mock_*.*,test_*.*,*test_util*.*,*_benchmark.*,*_test.*,*_tester.*,*unittest.* | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\*" -Include *.cc `
  -Exclude main*.cc,fake_*.*,mock_*.*,test_*.*,*test_util*.*,*_benchmark.*,*_test.*,*_tester.*,*unittest.* | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include *.h `
  -Exclude fake_*.*,mock_*.*,test_*.*,*test_util*.*,*_benchmark.*,*_test.*,*_tester.*,*unittest.* | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\*" -Include *.cc `
  -Exclude fake_*.*,mock_*.*,test_*.*,*test_util*.*,*_benchmark.*,*_test.*,*_tester.*,*unittest.* | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojprotoc +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\field_generators\*" -Include *.h `
  -Exclude fake_*.*,mock_*.*,test_*.*,*test_util*.*,*_benchmark.*,*_test.*,*_tester.*,*unittest.* | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*\\src\\", "..\..\src\"
  $filtersprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojprotoc +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\src\google\protobuf\compiler\cpp\field_generators\*" -Include *.cc `
  -Exclude fake_*.*,mock_*.*,test_*.*,*test_util*.*,*_benchmark.*,*_test.*,*_tester.*,*unittest.* | `
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

$dirfilterspath = [string]::format("{0}/protobuf_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $dirfilterspath,
    $filtersheaders + $filtersinternal + $filterssources,
    [system.text.encoding]::utf8)

$protocfilterspath = [string]::format("{0}/protoc_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $protocfilterspath,
    $filtersprotoc,
    [system.text.encoding]::utf8)

$dirvcxprojpath = [string]::format("{0}/protobuf_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $dirvcxprojpath,
    $vcxprojheaders + $vcxprojinternal + $vcxprojsources,
    [system.text.encoding]::utf8)

$protocvcxprojpath = [string]::format("{0}/protoc_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $protocvcxprojpath,
    $vcxprojprotoc,
    [system.text.encoding]::utf8)
