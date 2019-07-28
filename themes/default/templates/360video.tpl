{include file="header.tpl"}
<div class="vidcontrols">
	<div class="bt-menu-trigger">
		<span></span>
	</div>
	<video autoplay="" controls="" id="video"><source src="{$video_fallback}" type="video/mp4"></video>
	<div class="player-controls">
		<span id="iconPlayPause" class="video-icon" title="Play/Pause"><img id="playbtn" src="{$theme_dir}images/play-30.png"></span>
		<span id="iconSeekBackward" class="video-icon" data-skip="-10" title="10s Backward"><img src="{$theme_dir}images/rewind-30.png"></span>
		<span id="iconSeekForward" class="video-icon" data-skip="10" title="10s Forward"><img src="{$theme_dir}images/fast-forward-30.png"></span>
		<span id="iconFullscreen" class="video-icon" title="Full Screen"><img src="{$theme_dir}images/fit-to-width-30.png"></span>
		<span class="inline nowrap player-btn">Seek: <input id="progress-bar" max="100" min="0" oninput="seek(this.value)" step="0.01" type="range" value="0"></span>
		<span class="inline nowrap player-btn">Playback Rate: <input id='playbackRate' max="2.5" min="0.5" name='playbackRate' step="0.1" type="range" value="1"></span>
		<span class="inline nowrap player-btn">Volume: <input class="inline" id="volume" max="1" min="0" name="volume" step="0.05" type="range" value="1"></span>
		<select id="bitrate_list" name="bitrate_list"><option selected="selected" value="auto">Auto Bitrate</option></select>
	</div>
</div>
{include file="menu.tpl"}
<div class="col content" id="content">
	<div id="container" ondragstart="return false;" ondrop="return false;">
		<canvas id="360canvas"></canvas>
		</menu>
	</div>
	<script src="lib/theta-view.js" type="module">
	</script> 
	<script>
		var url = "{$video_dash}";
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
			
			console.log(availablevideoBitrates);
			availablevideoBitrates.forEach(function(Bitrate) {
			  console.log(Math.floor(Bitrate.bitrate / 1000) + ' kbps');
				var sel = document.getElementById('bitrate_list');
				var opt = document.createElement('option');
				opt.appendChild( document.createTextNode(Math.floor(Bitrate.bitrate / 1000) + ' kbps') );
				opt.value = Bitrate.bitrate / 1000; 
				sel.appendChild(opt);
			});

		});

		const video  = document.getElementById('video');
		const progressBar  = document.getElementById('progress-bar');
		const toggle = document.getElementById('iconPlayPause');
		const skip_forward = document.getElementById('iconSeekBackward');
		const skip_backward = document.getElementById('iconSeekForward');
		const full_screen = document.getElementById('iconFullscreen');
		const volume = document.getElementById('volume');
		const playbackRate = document.getElementById('playbackRate');
		const bitrate_list = document.getElementById('bitrate_list');

		function togglePlay() {
			const playState = video.paused ? 'play' : 'pause';
			video[playState](); // Call play or paused method
		}

		function updateButton() {
			image = document.getElementById('playbtn');
			if (player.isPaused()) {
				image.src = "{$theme_dir}images/play-30.png";
			} else {
				image.src = "{$theme_dir}images/pause-30.png";
			}
		}

		function skip() {
			video.currentTime += parseFloat(this.dataset.skip);
		}

		function rangeUpdate() {
			video[this.name] = this.value;
		}

		function updateProgressBar() {
			// Work out how much of the media has played via the duration and currentTime parameters
			var percentage = Math.floor((100 / video.duration) * video.currentTime);
			// Update the progress bar's value
			progressBar.value = percentage;
			// Update the progress bar's text (for browsers that don't support the progress element)
			progressBar.innerHTML = percentage + '% played';
		}
	   
		function seek(e) {
			progress_val = e / 100;
			//var percent = e.offsetX / this.offsetWidth;
			video.currentTime = progress_val * video.duration;
			//progressBar.value = Math.floor(e / 100);
			progressBar.innerHTML = progressBar.value + '% played';
		}

		function scrub(e) {
			const scrubTime = (e.offsetX / progress.offsetWidth) * video.duration;
			video.currentTime = scrubTime;
		}
	   
		function goFullScreen(){
			var canvas = document.getElementById("container");
			if(canvas.requestFullScreen)
				canvas.requestFullScreen();
			else if(canvas.webkitRequestFullScreen)
				canvas.webkitRequestFullScreen();
			else if(canvas.mozRequestFullScreen)
				canvas.mozRequestFullScreen();
			window.addEventListener( 'resize', onWindowResize, false );
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

		// Event listeners
		video.addEventListener('click', togglePlay);
		video.addEventListener('play', updateButton);
		video.addEventListener('pause', updateButton);
		video.addEventListener('timeupdate', updateProgressBar, false);

		toggle.addEventListener('click', togglePlay);
		skip_forward.addEventListener('click', skip);
		skip_backward.addEventListener('click', skip);
		full_screen.addEventListener('click', goFullScreen);
		volume.addEventListener('change', rangeUpdate);
		volume.addEventListener('mousemove', rangeUpdate);
		playbackRate.addEventListener('change', rangeUpdate);
		playbackRate.addEventListener('mousemove', rangeUpdate);

		bitrate_list.addEventListener('change', selectBitrate);

		let mousedown = false;
	</script>
</div>
{include file="footer.tpl"}