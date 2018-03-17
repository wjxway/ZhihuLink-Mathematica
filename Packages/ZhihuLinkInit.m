Needs["GeneralUtilities`"];
$ZhihuLinkDirectory::usage = "ZhihuLink 的缓存目录.";
$ZhihuCookie::usage ="";
$ZhihuAuth::usage ="";
ZhihuLinkInit::usage ="";
Begin["`Private`"];
$ZhihuLinkDirectory=FileNameJoin[{$UserBaseDirectory,"ApplicationData","ZhihuLink"}];
ZhihuLinkGetCheck[];
ZhihuLinkInit[] :=Block[
	{zc0},
	$ZhihuCookie = Import[FindFile["zhihu.cookie"]];
	zc0=Select[StringSplit[StringDelete[$ZhihuCookie," "],";"],StringTake[#,5]=="z_c0="&];
	$ZhihuAuth="Bearer "<>StringTake[First@zc0,6;;-1];
];
End[] ;
SetAttributes[
	{},
	{Protected,ReadProtected}
];