<?php
require "init.php";
$video = isset($_GET['video']) ? $_GET['video'] : "";



if($video && file_exists ($video))
{
	$path = pathinfo($video);
	$smarty->assign('video_menu',$video_menu);
	$smarty->assign('video_dash',$video);
	$smarty->assign('video_fallback',$path['dirname']."/fallback.mp4");
	$smarty->display("360video.tpl");
}
else
{
	$smarty->assign('video_menu',$video_menu);
	$smarty->display("index.tpl");
}	