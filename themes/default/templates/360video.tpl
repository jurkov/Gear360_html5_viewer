{include file="header.tpl"}
{include file="menu.tpl"}
<div class="col content" id="content">
	<div id="container" ondragstart="return false;" ondrop="return false;">
		<video autoplay playsinline id="video" class="video_default"><source src="{$video_fallback}" type="video/mp4"></video>
		<canvas id="360canvas" class="canvas_default"></canvas>
		<div id="canvas_message" class="canvas_center"></div>
		<menu id="controls">
			<span class="video-icon all_controls"><b>{$title}</b></span>
			<br />
			<span id="iconShowHideMenu" class="video-icon" title="Toggle Menu"><img src="{$theme_dir}images/close-pane-48.png" id="showhidemenubtn1" class="video-button menu_default_visible"/><img src="{$theme_dir}images/open-pane-48.png" id="showhidemenubtn2" class="video-button menu_default_hidden"/></span>
			<span id="iconShowHide" class="video-icon" title="Toggle Controls"><img class="video-button" id="showhidebtn" src="{$theme_dir}images/control-panel-64.png"></span>
			<span id="all_controls" class="all_controls">
				<span id="iconPlayPause" class="video-icon" title="Play"><img class="video-button" id="playbtn" src="{$theme_dir}images/play-60.png"></span>
				<span id="iconSeekBackward" class="video-icon" data-skip="-10" title="10s Backward"><img class="video-button" src="{$theme_dir}images/rewind-60.png"></span>
				<span id="iconSeekForward" class="video-icon" data-skip="10" title="10s Forward"><img class="video-button" src="{$theme_dir}images/fast-forward-60.png"></span>
				<span id="iconPreviousFile" class="video-icon" title="Previous Video"><img class="video-button" src="{$theme_dir}images/node-up-60.png"></span>
				<span id="iconNextFile" class="video-icon" title="Next Video"><img class="video-button" src="{$theme_dir}images/node-down-60.png"></span>
				<span id="iconCamView" class="video-icon" title="Source View"><img class="video-button" id="videobtn" src="{$theme_dir}images/video-camera-60.png"></span>
				<span id="iconFullscreen" class="video-icon" title="Full Screen"><img class="video-button" src="{$theme_dir}images/fit-to-width-60.png"></span>
				<span class="inline nowrap player-btn video-icon">Seek: <input id="progress-bar" max="100" min="0" oninput="seek(this.value)" step="0.01" type="range" value="0"><label id="current">00:00</label>/<label id="duration">00:00</label></span>
				<span class="view_controls">
					<span class="inline nowrap player-btn video-icon">[Zoom: <input class="canv_slider" id="zoom_range" type="range" max="3" min=".4" step=".1" value="{$zoom}"><label id="zoom_range_label">{$zoom}x]</label></span>
					<span class="inline nowrap player-btn video-icon">[Up/Down: <input class="canv_slider" id="default_z_view" type="range" max="360" min="0" step="1" value="{$default_z}"><label id="default_z_view_label">{$default_z}°]</label></span>
					<span class="inline nowrap player-btn video-icon">[Left/Right: <input class="canv_slider" id="default_y_view" type="range" max="360" min="0" step="1" value="{$default_y}"><label id="default_y_view_label">{$default_y}°]</label></span>
					<span class="inline nowrap player-btn video-icon">[Rotate: <input class="canv_slider" id="default_x_view" type="range" max="360" min="0" step="1" value="{$default_x}"><label id="default_x_view_label">{$default_x}°]</label></span>
				</span>
				<span class="inline nowrap player-btn video-icon">Volume: <input class="inline" id="volume" max="1" min="0" name="volume" step="0.05" type="range" value="1"></span>
				<span class="video-icon"><select id="bitrate_list" name="bitrate_list"><option selected="selected" value="auto">Auto Bitrate</option></select></span>
			</span>
		</menu>
	</div>
	<script src="lib/theta-view.js" type="module">
	</script> 
	<script>
		var urlParams = new URLSearchParams(window.location.search);
		var url = urlParams.get('video')
		var initialConfig = {
			'streaming': {
				'abr': {
					limitBitrateByPortal: false,
					initialBitrate: { audio: {$initialAudioBitrate}, video: {$initialVideoBitrate} },
					autoSwitchBitrate: { audio: true, video: true }
				}
			}
		}
		
		var player = dashjs.MediaPlayer().create();
		player.updateSettings(initialConfig);
		player.initialize(document.querySelector("#video"), url, true);
		player.setAutoPlay(true);
		
		player.on("streamInitialized", function () {
			var availableBitrates = { menuType: 'bitrate' };
			availablevideoBitrates = player.getBitrateInfoListFor('video') || [];

			availablevideoBitrates.forEach(function(Bitrate) {
				var sel = document.getElementById('bitrate_list');
				var opt = document.createElement('option');
				opt.appendChild( document.createTextNode(Number((Bitrate.bitrate / 1000000).toFixed(1)) + ' Mbps') );
				opt.value = Math.round(Bitrate.bitrate / 1000) + 1; 
				sel.appendChild(opt);
			});

		});

		const container = document.getElementById("container");
		const video  = document.getElementById('video');
		const canvas_message = document.getElementById('canvas_message');
		const progressBar  = document.getElementById('progress-bar');
		const hide_controls = document.getElementById('iconShowHide');
		const toggle = document.getElementById('iconPlayPause');
		const skip_forward = document.getElementById('iconSeekBackward');
		const skip_backward = document.getElementById('iconSeekForward');
		const file_forward = document.getElementById('iconNextFile');
		const file_backward = document.getElementById('iconPreviousFile');
		const full_screen = document.getElementById('iconFullscreen');
		const cam_view = document.getElementById('iconCamView');
		const volume = document.getElementById('volume');
		const playbackRate = document.getElementById('playbackRate');
		const bitrate_list = document.getElementById('bitrate_list');
		const CurrentVideo = '{$video_dash}';
		const VideoList = {$file_list|json_encode}; 		

		function togglePlay() {
			const playState = video.paused ? 'play' : 'pause';
			video[playState](); // Call play or paused method
		}

		function updateButton() {
			image = document.getElementById('playbtn');
			if (player.isPaused()) {
				image.src = "{$theme_dir}images/play-60.png";
				toggle.setAttribute('title', 'Play');
			} else {
				image.src = "{$theme_dir}images/pause-60.png";
				toggle.setAttribute('title', 'Pause');
			}
			canvas_message.innerHTML = "";
		}

		function NextFile() {
			var i = VideoList.indexOf(CurrentVideo);
			i = i + 1; // increase i by one
			i = i % VideoList.length; // if we've gone too high, start from `0` again
			var url = "{$website_root}index.php?video=" + VideoList[i]
			window.location.href = url

		}
		
		function PrevFile() {
			var i = VideoList.indexOf(CurrentVideo);
			if (i === 0) { // i would become 0
				i = VideoList.length; // so put it at the other end of the array
			}
			i = i - 1; // decrease by one
			var url = "{$website_root}index.php?video=" + VideoList[i]
			window.location.href = url
		}

		function skip() {
			video.currentTime += parseFloat(this.dataset.skip);
		}
		

		function rangeUpdate() {
			video[this.name] = this.value;
			if(this.name == "playbackRate") {
				$("#pbrate").text((Number(this.value).toFixed(1)) + "x");
			}
		}

		function updateProgressBar() {
			// Work out how much of the media has played via the duration and currentTime parameters
			var percentage = Math.floor((100 / video.duration) * video.currentTime);
			// Update the progress bar's value
			progressBar.value = percentage;
			// Update the progress bar's text (for browsers that don't support the progress element)
			progressBar.innerHTML = percentage + '% played';
			// Update Text Labels
			updateProgressTime(this.currentTime, this.duration);
		}
		
		function updateProgressTime(currentTime, duration){
			$("#current").text(formatTime(currentTime)); //Change #current to currentTime
			$("#duration").text(formatTime(duration));
		}
		
		function formatTime(seconds) {
			if(isNaN(seconds)) {
				return "00:00"
			} else {
				var date = new Date(null);
				date.setSeconds(seconds);
				var hours = date.toISOString().substr(11, 2);
				if(hours == "00") {
					var result = date.toISOString().substr(14, 5);
				} else {
					var result = date.toISOString().substr(11, 8);
				}
				return result
			}
		}
	   
		function seek(e) {
			progress_val = e / 100;
			//var percent = e.offsetX / this.offsetWidth;
			video.currentTime = progress_val * video.duration;
			//progressBar.value = Math.floor(e / 100);
			progressBar.innerHTML = progressBar.value + '% played';
			canvas_message.innerHTML = "";
		}

		function scrub(e) {
			const scrubTime = (e.offsetX / progress.offsetWidth) * video.duration;
			video.currentTime = scrubTime;
		}
	   
		function goFullScreen(){
			if (!document.fullscreenElement) {
				container.requestFullscreen();
			} else {
				document.exitFullscreen();
			}
		}
	   
		function selectBitrate() {
			var sel_bitrate = bitrate_list.options[bitrate_list.selectedIndex].value;
			if(sel_bitrate == "auto")
			{
				var bitConfig = {
					'streaming': {
						'abr': {
							maxBitrate: { audio: -1, video: -1 },
							minBitrate: { audio: -1, video: -1 },
						}
					}
				}
				player.updateSettings(bitConfig);
			}
			else
			{
				var bitConfig = {
					'streaming': {
						'abr': {
							maxBitrate: { audio: -1, video: sel_bitrate },
							minBitrate: { audio: -1, video: sel_bitrate },
						}
					}
				}
				player.updateSettings(bitConfig);
			}
		}
		
		function EndPrompt() {
			var i = VideoList.indexOf(CurrentVideo);
			if (i === 0) { // i would become 0
				i = VideoList.length; // so put it at the other end of the array
			}
			i = i - 1; // decrease by one
			var PrevVideo = VideoList[i]
			var PrevPath = PrevVideo.substring(0, PrevVideo.lastIndexOf("/"));
			var PrevThumb = '{$website_root}' + PrevPath + '/thumbnail.png'
			var PrevLinkText = PrevVideo.replace('videos/', '');
			
			var i = VideoList.indexOf(CurrentVideo);
			i = i + 1; // increase i by one
			i = i % VideoList.length; // if we've gone too high, start from `0` again
			var NextVideo = VideoList[i]		
			var NextPath = NextVideo.substring(0, NextVideo.lastIndexOf("/"));
			var NextThumb = '{$website_root}' + NextPath + '/thumbnail.png'
			var NextLinkText = NextVideo.replace('videos/', '');
		
		
			canvas_message.innerHTML = '<div id="canvasNextFile" title="Next Video" class="canv_msg"><div>Next Video &rarr;<br />' + NextLinkText + '</div><div><img src="' + NextThumb + '" class="canv_thumb"></div></div><br /><div id="canvasPrevFile" title="Previous Video" class="canv_msg"><div>&larr; Previous Video<br />' + PrevLinkText + '</div><div><img src="' + PrevThumb + '" class="canv_thumb"></div></div>';
			var canv_file_forward = document.getElementById('canvasNextFile');
			var canvfile_backward = document.getElementById('canvasPrevFile');
			canv_file_forward.addEventListener('click', NextFile);
			canvfile_backward.addEventListener('click', PrevFile);
		}

		function toggleVideo() {
			$('.video_default').toggleClass('active');
			$('.canvas_default').toggleClass('hidden');
			$('.view_controls').toggleClass('hidden');
		   var resizeEvent = window.document.createEvent('UIEvents'); 
		   resizeEvent.initUIEvent('resize', true, false, window, 0); 
		   window.dispatchEvent(resizeEvent);
		   
		   	var videobtn = document.getElementById('videobtn');
			if (video.classList.contains("active")) {
				videobtn.src = "{$theme_dir}images/panorama-60.png";
				cam_view.setAttribute('title', '360 View');
			} else {
				videobtn.src = "{$theme_dir}images/video-camera-60.png";
				cam_view.setAttribute('title', 'Source View');
			}
		}
		
		function HideControls() {
			$('.all_controls').toggleClass('hidden');
		}

		// Event listeners
		video.addEventListener('click', togglePlay);
		video.addEventListener('play', updateButton);
		video.addEventListener('pause', updateButton);
		video.addEventListener('timeupdate', updateProgressBar, false);
		video.addEventListener("loadeddata", updateProgressBar, false);
		video.addEventListener('ended',EndPrompt,false);

		toggle.addEventListener('click', togglePlay);
		hide_controls.addEventListener('click', HideControls);
		skip_forward.addEventListener('click', skip);
		skip_backward.addEventListener('click', skip);
		file_forward.addEventListener('click', NextFile);
		file_backward.addEventListener('click', PrevFile);
		full_screen.addEventListener('click', goFullScreen);
		cam_view.addEventListener('click', toggleVideo);
		volume.addEventListener('change', rangeUpdate);
		volume.addEventListener('mousemove', rangeUpdate);
		playbackRate.addEventListener('change', rangeUpdate);
		playbackRate.addEventListener('mousemove', rangeUpdate);

		bitrate_list.addEventListener('change', selectBitrate);

		let mousedown = false;
	</script>
</div>
{include file="footer.tpl"}
