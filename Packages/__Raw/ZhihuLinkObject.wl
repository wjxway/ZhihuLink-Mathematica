(* Mathematica Package *)
(* Created by Mathematica Plugin for IntelliJ IDEA *)

(* :Title: ZhihuLinkObject *)
(* :Context: ZhihuLinkObject` *)
(* :Author: 28059 *)
(* :Date: 2018-03-19 *)

(* :Package Version: 0.1 *)
(* :Mathematica Version: *)
(* :Copyright: (c) 2018 28059 *)
(* :Keywords: *)
(* :Discussion: *)

BeginPackage["ZhihuLinkObject`"];
ZhihuLinkObject::usage="";
ZhihuConnect::usage="";

Begin["`Object`"];
$ZhihuLinkIcon=Import[DirectoryName@FindFile["ZhihuLink`ZhihuLinkLoader`"]<>"ZhihuLinkLogo.png"];
CookiesGetMe[cookie_,auth_]:=Block[
	{req=HTTPRequest[
		"https://api.zhihu.com/people/self",
		<|
			"Headers"-><|"authorization"->auth|>,
			"Cookies"->cookie,
			"Query"->{"include"->"gender,voteup_count,follower_count,account_status"}
		|>]},
	GeneralUtilities`ToAssociations@URLExecute[req,Authentication->None,Interactive->False]
]//Quiet;
ZhihuConnect[cookie_String]:=Block[
	{zc0,auth,me,img},
	zc0=Select[StringSplit[StringDelete[cookie," "],";"],StringTake[#,5]=="z_c0="&];
	auth="Bearer "<>StringTake[First@zc0,6;;-1];
	me=CookiesGetMe[cookie,auth];
	Switch[me["error","code"],
		100,Text@Style["验证失败, 请刷新此 cookie",Darker@Red]//Return,
		40352,Text@Style["该账号已被限制, 请手动登陆解除限制",Darker@Red]//Return,
		_,Text@Style["Login Successfully!",Darker@Green]//Print
	];
	img=ImageResize[URLExecute[StringTake[me["avatar_url"],1;;-6]<>"r.jpg","jpg"],52];
	ZhihuLinkUserObject[<|
		"cookies"->cookie,
		"auth"->auth,
		"user"->Text@Style[me["url_token"],Darker@Blue],
		"img"->img
	|>]
];
Format[ZhihuLinkUserObject[___],OutputForm]:="ZhihuLinkUserObject[<>]";
Format[ZhihuLinkUserObject[___],InputForm]:="ZhihuLinkUserObject[<>]";
ZhihuLinkUserObjectQ[asc_?AssociationQ]:=AllTrue[{"cookies","auth","user"},KeyExistsQ[asc,#]&];
ZhihuLinkUserObjectQ[_]=False;
ZhihuLinkUserObject/:MakeBoxes[obj:ZhihuLinkUserObject[asc_?ZhihuLinkUserObjectQ],form:(StandardForm|TraditionalForm)]:=Module[
	{above,below},
	above={
		{BoxForm`SummaryItem[{"KeyID: ",Hash@asc["cookies"]}],SpanFromLeft},
		{BoxForm`SummaryItem[{"User: ",asc["user"]}],SpanFromLeft},
		{BoxForm`SummaryItem[{"Validity: ",Text@Style["\[Checkmark] Success!",Darker@Green]}],SpanFromLeft}
	};
	below={};
	BoxForm`ArrangeSummaryBox[
		"ServiceObject",
		obj,
		asc["img"],
		above,
		below,
		form,
		"Interpretable"->Automatic
	]
];

Answer2Data[post_]:=Block[
	{title=post["question","title"],qa,link},
	qa=<|"q"->post["question","id"],"a"->post["id"]|>;
	link=StringTemplate["https://www.zhihu.com/questions/`q`/answers/`a`"][qa];
	<|
		"title"->Hyperlink[title,link],
		"vote"->post["voteup_count"],
		"comment"->post["comment_count"],
		"created time"->FromUnixTime@post["created_time"]
	|>
];
Article2Data[post_]:=Block[
	{title=post["title"],link=post["url"]},
	<|
		"title"->Hyperlink[title,link],
		"vote"->post["voteup_count"],
		"comment"->post["comment_count"],
		"created time"->FromUnixTime@post["created"]
	|>
];
Options[ObjectPost]={SortBy->"vote",Times->True,Save->False};
ObjectPost[user_String,OptionsPattern[]]:=Block[
	{ans,art,data,now=Now},
	If[OptionValue[Save],
		ZhihuAnswerBackup[user];
		Return[$ZhihuLinkMarkdown]
	];
	ans=ZhihuLinkUserAnswer[user,Save->False,Extension->"data[*].voteup_count,comment_count"];
	art=ZhihuLinkUserArticle[user,Save->False,Extension->"data[*].voteup_count,comment_count"];
	data=Reverse@Dataset[Join[Answer2Data/@ans,Article2Data/@art]][SortBy[OptionValue[SortBy]]];
	If[OptionValue[Times],Echo[Now-now,"Time Used: "]];
	Return@data
];
ZhihuLinkUserObject[ass_]["Post",ops_List]:=Block[
	{
		$ZhihuCookie=Lookup[ass,"cookie"],
		$ZhihuAuth=Lookup[ass,"auth"]
	},
	ObjectPost@@ops
];
End[];

EndPackage[];