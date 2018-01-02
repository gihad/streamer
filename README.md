# Streamer

This docker image will start a container that can take existing streams (e.g.: rtsp streams from your security cameras) and use FFMPEG to convert it into HLS streams and drop them in a folder that Nginx is serving.

In order to cast an HLS stream to chromecast devices the server needs to contain certain headers (e.g.: CORS headers, correct content type) which is being done here in Nginx.
(PS: Make sure you are comfortable with the `Access-Control-Allow-Origin *` header)

The HLS stream that chromecast accepts has some additional restrictions, such as limited audio and video codec support. This image will check if the codecs are AAC and h264 for audio and video, if they are are it will use the copy command in ffmpeg (low cpu usage) if not it will transcode the original stream so that the chromecast can stream it.

Chromecast devices also don't seem to support HLS streams without an audio track, this image will also generate a dummy silent audio track if your original stream is lacking sound (Not uncommon for security cameras).

### Running

#### Build the image
(optional)

`docker build . -t gihad/streamer`

#### Run with docker
Need to expose the port, mount the volume and pass in parameters

`docker run -e PARAMETERS="INPUT_STREAM_1 STREAM_1_NAME INPUT_STREAM_2 STREAM_2_NAME" -v host_volume:container_volume -p host_port:container_port gihad/streamer`

Example:

`docker run -e PARAMETERS="rtsp://username:password@192.168.1.183:554/cam/realmonitor?channel=1&subtype=1 frontyard rtsp://username:password@192.168.1.183:554/cam/realmonitor?channel=2&subtype=1 driveway" -v /tmp/stream:/tmp/stream -p 8080:80 gihad/streamer`

### Paramaters format
The parameters need to be passed in as a single environment variable called PARAMETERS separated by spaces in the following format:

`INPUT_STREAM_1 STREAM_1_NAME INPUT_STREAM_2 STREAM_2_NAME`

Input followed by stream name. In the example above 2 streams will be created but the program supports more than 2.

### Accessing the stream(s)

The streams will be accessible on port 8080 and the resource will be the chosen stream name suffixed with .m3u8.

Example: if the address of the host is `192.168.1.100` and the name of the stream passed as a parameter was `driveway` you will find the HLS steam at `http://192.168.1.100:8080/driveway.m3u8`

### Tips

I was able to run multiple HLS streams on a Raspberry Pi 1, in order to that I needed to set the input stream from the cameras to use AAC and h264, in this case the container running ffmpeg could just use the `copy` command for the codecs instead of having to transcode it.
